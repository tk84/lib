# -*- coding: utf-8 -*-

require 'singleton'
module Tk84
  class Extsource
    include Singleton

    def initialize
      @source = {}
      @parser = {}
      @parsed = {}
    end

    def method_missing type, *args
      id = args.shift

      if not @parsed[type][id]
        parser = @parser[type].new
        parser.parse(@source[type][id])
        @parsed[type][id] = parser
      elsif
        parser = @parsed[type][id]
      end

      parser.result(*args)
    end

    def parser type, parser
      @parser.store type.to_sym, parser
      @parsed[type] = {} if not @parsed[type]
    end

    def source type, *args
      (args[0].kind_of?(Hash) ? args[0] : Hash[*args]).each_pair do |key, value|
        @parsed[type][key] = nil if @parsed[type] && @parsed[type][key]
        @source[type] = {} if not @source[type]
        @source[type][key] = value
      end
    end

    def debug
      p @source
      p @parser
      p @parsed
    end

    class Sql
      def initialize
        @result = {}
      end

      def parse source
        res = nil
        File.open(source, 'r') do |file|
          contents = file.read
          contents.scan /(?=^|\n)--:([\w]+)((?!\n--:[\w+])\n[^\n]*)*/ do |s|
            id = Regexp.last_match(1).to_sym
            @result.store id, Regexp.last_match(0)
          end
        end
      end

      def result id, placeholder={}
        result = @result[id].dup

        placeholder.each_pair do |key,value|
          result.gsub! "\#{#{key}}", value
        end

        result
      end
    end
  end
end
