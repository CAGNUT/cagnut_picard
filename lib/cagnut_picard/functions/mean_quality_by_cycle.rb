module CagnutPicard
  class MeanQualityByCycle
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :jobs_dir, :java_path,
                   :ref_fasta, :prefix_name, :dodebug
    def_delegators :'CagnutPicard.config', :mean_quality_by_cycle_params

    def initialize opts = {}
      @order = sprintf '%02i', opts[:order]
      @tmp_dir = opts[:dirs][:tmp_dir]
      @job_name = "#{prefix_name}_meanQbycycle_#{sample_name}"
      @input = opts[:input].nil? ? "#{opts[:dirs][:input]}/#{sample_name}_recal.bam" : opts[:input]
      @output = "#{opts[:dirs][:output]}/quality_table"
      @chart_output= "#{opts[:dirs][:output]}/qualityByCycle_#{sample_name}.pdf"
    end

    def run previous_job_id = nil
      puts "Submitting Picard MeanQualityByCycle #{sample_name} Jobs"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        adjust_memory: ['h_vmem=5G'],
        tools: ['picard', 'mean_quality_by_cycle']
      }
    end

    def mean_quality_by_cycle_options
      array = mean_quality_by_cycle_params['params'].dup
      array << "INPUT=#{@input}"
      array << "OUTPUT=#{@output}"
      array << "TMP_DIR=#{@tmp_dir}"
      array << "CHART_OUTPUT=#{@chart_output}"
      array.uniq
    end

    def modified_java_array
      array = mean_quality_by_cycle_params['java'].dup
      array << 'MeanQualityByCycle'
      array.unshift(java_path).uniq
    end

    def params_combination_hash
      @params_combination_hash ||= {
        'java' => modified_java_array,
        'params' => mean_quality_by_cycle_options
      }
    end

    def generate_script
      script_name = "#{@order}_picard_meanQbycycle"
      file = File.join jobs_dir, "#{script_name}.sh"
      File.open(file, 'w') do |f|
        f.puts <<-BASH.strip_heredoc
          #!/bin/bash

          cd "#{jobs_dir}/../"
          echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
          #{params_combination_hash['java'].join("\s")} \\
            #{params_combination_hash['params'].join(" \\\n            ")} \\
            #{::Cagnut::JobManage.run_local}

          EXITSTATUS=$?
          if [ ! -s "#{@chart_output}" ]; then exit 100;fi;
          echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"

          exit $EXITSTATUS
        BASH
      end
      File.chmod(0700, file)
      script_name
    end
  end
end
