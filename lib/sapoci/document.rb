# encoding: utf-8

require 'rubygems' unless RUBY_VERSION >= '1.9'
require 'nokogiri'
require 'sapoci/core_ext'

module SAPOCI
  # SAPOCI::Document is for parsing and emitting SAP OCI compliant
  # data. 
  # 
  # Open a +Document+ by feeding it a string:
  # 
  #   doc = SAPOCI::Document.from_html("<html>...</html>")
  # 
  # Open a +Document+ by parsing a Rails-/Rack compatible +Hash+:
  # 
  #   doc = SAPOCI::Document.from_params({ "NEW_ITEM-DESCRIPTION"=>{"1"=>"Standard Visitenkarte deutsch 200 St."} })
  #
  class Document
    def initialize(items)
      @items = items
    end
    
    # Create a new document from a HTML string.
    def self.from_html(html)
      html_doc = Nokogiri::HTML(html)
      doc = Document.new(parse_html(html_doc))
      yield doc if block_given?
      doc
    end
    
    # Create a new document from a Rails-/Rack-compatible 
    # params hash.
    def self.from_params(params)
      doc = Document.new(parse_params(params))
      yield doc if block_given?
      doc
    end
    
    # All +Item+ instances.
    attr_reader :items
    
    # Returns all +items+ as HTML hidden field tags.
    def to_html(options = {})
      html = []
      self.items.each do |item|
        html << item.to_html(options)
      end
      html.join
    end
    
  private
    
    # Parses a Nokogiri HTML document and returns
    # +Item+ instances in an array.
    def self.parse_html(doc)
      items = {}
      doc.xpath("//input[starts-with(@name, 'NEW_ITEM-')]").each do |item_node|
        name = item_node.attribute("name")
        if /NEW_ITEM-(\w+)\[(\d+)\]/.match(name)
          property = $1
          index = $2.to_i - 1
          value = item_node.attribute("value").value
          items[index] = Item.new(index) unless items[index]
          items[index].send((property+'=').downcase.to_sym, value)
        elsif /NEW_ITEM-LONGTEXT_(\d+):132/.match(name)
          index = $1.to_i - 1
          value = item_node.attribute("value").value
          items[index] = Item.new(index) unless items[index]
          items[index].longtext = value
        end
      end
      items.inject([]) { |memo, (key, value)| memo << value }.sort_by(&:index)
    end
    
    # Parses a Rails-/Rack-compatible params hash and returns
    # +Item+ instances in an array.
    def self.parse_params(params)
      items = {}
      (params || {}).each do |oci_name, oci_values|
        if oci_name =~ /NEW_ITEM-/
          # Parse anything but NEW_ITEM-LONGTEXT (which is special, see below)
          oci_values.each do |index, value|
            index = index.to_i - 1 rescue next
            property = /NEW_ITEM-(\w+)/.match(oci_name)[1]
            next if property =~ /LONGTEXT/ 
            method = (property+'=').downcase.to_sym
            items[index] = Item.new(index) unless items[index]
            items[index].send(method, value) if items[index].respond_to?(method)
          end if oci_values && oci_values.respond_to?(:each)
          
          # LONGTEXT is a special case because it doesn't follow the conventions
          # Format is:
          #   NEW_ITEM-LONTEXT_n:132[]
          # But shops use other (invalid) formats as well (and we're ready to accept them):
          #   NEW_ITEM-LONGTEXT_n:132[n]
          #   NEW_ITEM_LONGTEXT_n:132
          #
          if /NEW_ITEM-LONGTEXT_(\d+):132/.match(oci_name)
            index = $1.to_i - 1
            if oci_values.is_a?(Array)
              # NEW_ITEM-LONGTEXT_1:132[]
              items[index] = Item.new(index) unless items[index]
              items[index].longtext = oci_values.first
            elsif oci_values.is_a?(String)
              # NEW_ITEM-LONGTEXT_1:132 <= invalid but parsed!
              items[index] = Item.new(index) unless items[index]
              items[index].longtext = oci_values
            elsif oci_values.is_a?(Hash)
              # NEW_ITEM-LONGTEXT_1:132[1] <= invalid but parsed!
              items[index] = Item.new(index) unless items[index]
              items[index].longtext = oci_values.first.last
            end
          end if oci_values
        end # oci_name =~ /NEW_ITEM-/
      end
      items.inject([]) { |memo, (key, value)| memo << value }.sort_by(&:index)
    end
    
  end
end
