class MissingManifest < ActiveRecord::Base
  # Include helpers
  include ActionView::Helpers

  scope :recent, lambda {|options| 
    scope = MissingManifest.scoped
    if options[:since_time].present?
      scope = scope.where("created_at > ?", options[:since_time])
    else
      MissingManifest.where("created_at > ?", 7.days.ago)
    end
    scope = scope.limit(options[:limit]) if options[:limit].present?
    scope.order("created_at DESC")
  }
  
  def request_ip=(value)
    self.hostname = get_hostname(value)
    super(value)
  end
  
  def get_hostname(ip)
    Socket.gethostbyaddr(ip.split(".").map(&:to_i).pack("CCCC")).first
  end
  
  def request_time
    s = nil
    if created_at > 5.days.ago
			s = time_ago_in_words(created_at) + " ago"
		else
		  s = created_at.getlocal.to_s(:readable_detail)
		end
		s
  end
  
  def to_s
    if hostname.present?
      hostname
    else
      request_ip
    end
  end
end

