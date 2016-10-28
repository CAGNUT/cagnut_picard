module CagnutPicard
  class QualityScoreDistribution
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :jobs_dir, :java_path,
                   :ref_fasta, :prefix_name, :dodebug
    def_delegators :'CagnutPicard.config', :quailty_score_distribution_params

    def initialize opts = {}
      @tmp = opts[:dirs][:tmp_dir]
      @job_name = "#{prefix_name}_meanQScDis_#{sample_name}"
      @input = opts[:input].nil? ? "#{opts[:dirs][:input]}/#{sample_name}_recal.bam" : opts[:input]
      @output = "#{opts[:dirs][:output]}/quality_table"
      @chart_output = "#{opts[:dirs][:output]}/quality_filter_score_#{sample_name}.pdf"
    end

    def run previous_job_id = nil
      puts "Submitting Picard QualityScoreDistribution #{sample_name} Jobs"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        adjust_memory: ['h_vmem=5G'],
        tools: ['picard', 'quailty_score_distribution']
      }
    end

    def quailty_score_distribution_options
      array = quailty_score_distribution_params['params'].dup
      array << "INPUT=#{@input}"
      array << "OUTPUT=#{@output}"
      array << "CHART_OUTPUT=#{@chart_output}"
      array << "TMP_DIR=#{@tmp_dir}"
      array.uniq
    end

    def modified_java_array
      array = quailty_score_distribution_params['java'].dup
      array << 'QualityScoreDistribution'
      array.unshift(java_path).uniq
    end

    def params_combination_hash
      @params_combination_hash ||= {
        'java' => modified_java_array,
        'params' => quailty_score_distribution_options
      }
    end

    def generate_script
      script_name = 'picard_meanQScDis'
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
