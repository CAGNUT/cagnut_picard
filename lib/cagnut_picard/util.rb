module CagnutPicard
  class Util
    attr_accessor :picard, :config

    def initialize config
      @config = config
      @picard = CagnutPicard::Base.new
    end

    def add_or_replace_readgroups dirs, previous_job_id, filename
      picard.add_or_replace_readgroups dirs, previous_job_id, filename
    end

    def markdup dirs, previous_job_id, filename = nil
      picard.markdup dirs, previous_job_id, filename
    end

    def build_bam_index dirs, previous_job_id, filename = nil
      picard.build_bam_index dirs, previous_job_id, filename
    end

    def picard_qc_metrics dirs, previous_job_id, filename
      picard.mean_quality_by_cycle dirs, previous_job_id, filename
      picard.quality_score_distribution dirs, previous_job_id, filename
      picard.collect_gc_bias_metrics dirs, previous_job_id, filename
      picard.collect_insert_size_metrics dirs, previous_job_id, filename
    end

    def sort_sam dirs, previous_job_id, filename
      picard.sort_sam dirs, previous_job_id, filename
    end

    def collect_multiple_metrics dirs, previous_job_id, filename
      picard.collect_multiple_metrics dirs, previous_job_id, filename
    end
  end
end
