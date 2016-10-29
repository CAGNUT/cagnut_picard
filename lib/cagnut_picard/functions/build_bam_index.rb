module CagnutPicard
  class BuildBamIndex
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :prefix_name,
                   :jobs_dir, :dodebug, :java_path
    def_delegators :'CagnutPicard.config', :build_bam_index_params

    def initialize opts = {}
      @order = sprintf '%02i', opts[:order]
      @job_name = "#{prefix_name}_build_bam_index_#{sample_name}"
      @input = opts[:input].nil? ? "#{opts[:dirs][:input]}/#{sample_name}_markdup.bam" : opts[:input]
    end

    def run previous_job_id = nil
      puts "Submitting build_bam_index #{sample_name}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        adjust_memory: ['h_vmem=10G'],
        tools: ['picard', 'build_bam_index']
      }
    end

    def build_bam_index_options
      array = build_bam_index_params['params'].dup
      array << "I=#{@input}"
      array.uniq.compact
    end

    def modified_java_array
      array = build_bam_index_params['java'].dup
      array << 'BuildBamIndex'
      array.unshift(java_path).uniq
    end

    def params_combination_hash
      @params_combination_hash ||= {
        'java' => modified_java_array,
        'params' => build_bam_index_options
      }
    end

    def generate_script
      script_name = "#{@order}_picard_build_bam_index"
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
