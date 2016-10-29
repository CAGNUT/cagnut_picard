module CagnutPicard
  class Util
    attr_accessor :picard, :config

    def initialize config
      @config = config
      @picard = CagnutPicard::Base.new
    end

    def add_or_replace_readgroups dirs, order, previous_job_id, filename
      job_name, filename = picard.add_or_replace_readgroups dirs, order, previous_job_id, filename
      [job_name, filename, order+1]
    end

    def markdup dirs, order=1, previous_job_id=nil, filename=nil
      job_name, filename = picard.markdup dirs, order, previous_job_id, filename
      [job_name, filename, order+1]
    end

    def build_bam_index dirs, order=1, previous_job_id=nil, filename=nil
      job_name = picard.build_bam_index dirs, order, previous_job_id, filename
      [job_name, order+1]
    end

    def picard_qc_metrics dirs, order, previous_job_id, filename
      order = mean_quality_by_cycle dirs, order, previous_job_id, filename
      order = quality_score_distribution dirs, order, previous_job_id, filename
      order = collect_gc_bias_metrics dirs, order, previous_job_id, filename
      collect_insert_size_metrics dirs, order, previous_job_id, filename
    end

    def mean_quality_by_cycle dirs, order, previous_job_id, filename
      picard.mean_quality_by_cycle dirs, order, previous_job_id, filename
      order+1
    end

    def quality_score_distribution dirs, order, previous_job_id, filename
      picard.quality_score_distribution dirs, order, previous_job_id, filename
      order+1
    end

    def collect_gc_bias_metrics dirs, order, previous_job_id, filename
      picard.collect_gc_bias_metrics dirs, order, previous_job_id, filename
      order+1
    end

    def collect_insert_size_metrics dirs, order, previous_job_id, filename
      picard.collect_insert_size_metrics dirs, order, previous_job_id, filename
      order+1
    end

    def sort_sam dirs, order=1, previous_job_id, filename
      job_name, filename = picard.sort_sam dirs, order, previous_job_id, filename
      [job_name, filename, order+1]
    end

    def collect_multiple_metrics dirs, order=1, previous_job_id, filename
      picard.collect_multiple_metrics dirs, order, previous_job_id, filename
      order+1
    end
  end
end
