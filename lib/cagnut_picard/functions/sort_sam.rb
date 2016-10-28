module CagnutPicard
  class SortSam
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :dodebug,
                   :jobs_dir, :magic28, :ref_fasta, :prefix_name, :java_path
    def_delegators :'CagnutPicard.config', :rg_str_picard, :sort_sam_params

    def initialize opts = {}
      @input = opts[:input].nil? ? "#{opts[:dirs][:input]}/#{sample_name}_mem.sam" : opts[:input]
      @output = "#{opts[:dirs][:output]}/#{sample_name}_sort.bam"
      @job_name = "#{prefix_name}_sort_sam_#{sample_name}"
    end

    def run previous_job_id = nil
      puts "Submitting sort_sam #{sample_name}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      [@job_name, @output]
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        tools: ['picard', 'sort_sam']
      }
    end

    def sort_sam_options
      array = sort_sam_params['params'].dup
      array << "I=#{@input}"
      array << "O=#{@output}"
      array.uniq
    end

    def modified_java_array
      array = sort_sam_params['java'].dup
      array << 'SortSam'
      array.unshift(java_path).uniq
    end

    def params_combination_hash
      @params_combination_hash ||= {
        'java' => modified_java_array,
        'params' => sort_sam_options
      }
    end

    def generate_script
      script_name = 'picard_sort_sam'
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

          if [ ! -e "#{@output}" ]
          then
            echo "Missing output: #{@output}"
            exit 100
          fi

          # Check BAM EOF
          BAM_28=$(tail -c 28 #{@output}|xxd -p)
          if [ '#{magic28}' != "$BAM_28" ]
          then
            echo "Error with BAM EOF" 1>&2
            exit 100
          fi

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
