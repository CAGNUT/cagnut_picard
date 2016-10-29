module CagnutPicard
  class CollectMultipleMetrics
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :dodebug, :prefix_name,
                   :jobs_dir, :magic28, :java_path, :ref_fasta
    def_delegators :'CagnutPicard.config', :rg_str_picard, :collect_multiple_metrics_params

    def initialize opts = {}
      @order = sprintf '%02i', opts[:order]
      @input = opts[:input].nil? ? "#{opts[:dirs][:input]}/#{sample_name}_recal.bam" : opts[:input]
      @output = "#{opts[:dirs][:output]}/#{sample_name}_multiple_metrics"
      @job_name = "#{prefix_name}_CollectMultipleMetrics_#{sample_name}"
    end

    def run previous_job_id = nil
      puts "Submitting CollectMultipleMetrics #{sample_name}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        var_env: [rg_str_picard],
        adjust_memory: ['h_vmem=10G'],
        tools: ['picard', 'collect_multiple_metrics']
      }
    end

    def collect_multiple_metrics_options
      array = collect_multiple_metrics_params['params'].dup
      array << "REFERENCE_SEQUENCE=#{ref_fasta}"
      array << "I=#{@input}"
      array << "O=#{@output}"
      array.uniq

    end

    def modified_java_array
      array = collect_multiple_metrics_params['java'].dup
      array << 'CollectMultipleMetrics'
      array.unshift(java_path).uniq
    end

    def params_combination_hash
      @params_combination_hash ||= {
        'java' => modified_java_array,
        'params' => collect_multiple_metrics_options
      }
    end

    def generate_script
      script_name = "#{@order}_picard_collect_multiple_metrics"
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

          if [ $EXITSTATUS -ne 0 ];then exit $EXITSTATUS;fi
          echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"

          exit $EXITSTATUS
        BASH
      end
      File.chmod(0700, file)
      script_name
    end
  end
end
