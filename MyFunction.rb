# -*- coding: utf-8 -*-

require 'digest'
module Tk84
  module MyFunction
    def self.uniqid
      Digest::MD5.hexdigest('tk84' + Time.now.instance_eval { '%s.%06d' % [strftime('%Y%m%d%H%M%S'), usec] })
    end
  end
end
