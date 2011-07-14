# encoding: utf-8

require 'rubygems' unless RUBY_VERSION >= '1.9'
require 'nokogiri'
require 'sapoci/core_ext'
require 'bigdecimal'

module SAPOCI
  class Item
    
    attr_reader :index
    attr_accessor :description
    attr_accessor :matnr
    attr_accessor :quantity
    attr_accessor :unit
    attr_accessor :price
    attr_accessor :currency
    attr_accessor :priceunit
    attr_accessor :leadtime
    attr_accessor :longtext
    attr_accessor :vendor
    attr_accessor :vendormat
    attr_accessor :manufactcode
    attr_accessor :manufactmat
    attr_accessor :matgroup
    attr_accessor :service
    attr_accessor :contract
    attr_accessor :contract_item
    attr_accessor :ext_quote_id
    attr_accessor :ext_quote_item
    attr_accessor :ext_product_id
    attr_accessor :attachment
    attr_accessor :attachment_title
    attr_accessor :attachment_purpose
    attr_accessor :ext_schema_type
    attr_accessor :ext_category_id
    attr_accessor :ext_category
    attr_accessor :sld_sys_name
    attr_accessor :cust_field1
    attr_accessor :cust_field2
    attr_accessor :cust_field3
    attr_accessor :cust_field4
    attr_accessor :cust_field5
    
    # Initializes the item.
    def initialize(index)
      @index = index
    end
    
    def quantity
      BigDecimal.new("0#{@quantity.to_s.strip}")
    end

    def quantity_before_type_cast
      @quantity
    end
    
    def price
      BigDecimal.new("0#{@price.to_s.strip}")
    end
    
    def price_before_type_cast
      @price
    end

    def priceunit
      BigDecimal.new("0#{@priceunit.to_s.strip}")
    end
    
    def priceunit_before_type_cast
      @priceunit
    end

    def leadtime
      @leadtime.to_i if @leadtime
    end

    def leadtime_before_type_cast
      @leadtime
    end
    
    def service?
      self.service == "X"
    end

    # Returns the item properties as HTML hidden field tags.
    def to_html(options = {})
      html = []
      html << hidden_field_tag("DESCRIPTION",     self.description)     unless self.description.blank?
      html << hidden_field_tag("MATNR",           self.matnr)           unless self.matnr.blank?
      html << hidden_field_tag("QUANTITY",        "%015.3f" % self.quantity)
      html << hidden_field_tag("UNIT",            self.unit)            unless self.unit.blank?
      html << hidden_field_tag("PRICE",           "%015.3f" % self.price)
      html << hidden_field_tag("CURRENCY",        self.currency)        unless self.currency.blank?
      html << hidden_field_tag("PRICEUNIT",       self.priceunit.to_i)  if self.priceunit.to_i > 0
      html << hidden_field_tag("LEADTIME",        "%05d" % self.leadtime) if self.leadtime.to_i > 0
      html << hidden_field_tag("VENDOR",          self.vendor)          unless self.vendor.blank?
      html << hidden_field_tag("VENDORMAT",       self.vendormat)       unless self.vendormat.blank?
      html << hidden_field_tag("MANUFACTCODE",    self.manufactcode)    unless self.manufactcode.blank?
      html << hidden_field_tag("MANUFACTMAT",     self.manufactmat)     unless self.manufactmat.blank?
      html << hidden_field_tag("MATGROUP",        self.matgroup)        unless self.matgroup.blank?
      html << hidden_field_tag("SERVICE",         "X")                  if     self.service?
      html << hidden_field_tag("CONTRACT",        self.contract)        unless self.contract.blank?
      html << hidden_field_tag("CONTRACT_ITEM",   self.contract_item)   unless self.contract_item.blank?
      html << hidden_field_tag("EXT_QUOTE_ID",    self.ext_quote_id)    unless self.ext_quote_id.blank?
      html << hidden_field_tag("EXT_QUOTE_ITEM",  self.ext_quote_item)  unless self.ext_quote_item.blank?
      html << hidden_field_tag("EXT_PRODUCT_ID",  self.ext_product_id)  unless self.ext_product_id.blank?
      html << hidden_field_tag("ATTACHMENT",      self.attachment)      unless self.attachment.blank?
      html << hidden_field_tag("ATTACHMENT_TITLE", self.attachment_title) unless self.attachment_title.blank?
      html << hidden_field_tag("ATTACHMENT_PURPOSE", self.attachment_purpose) unless self.attachment_purpose.blank?
      html << hidden_field_tag("EXT_SCHEMA_TYPE", self.ext_schema_type) unless self.ext_schema_type.blank?
      html << hidden_field_tag("EXT_CATEGORY_ID", self.ext_category_id) unless self.ext_category_id.blank?
      html << hidden_field_tag("EXT_CATEGORY",    self.ext_category)    unless self.ext_category.blank?
      html << hidden_field_tag("SLD_SYS_NAME",    self.sld_sys_name)    unless self.sld_sys_name.blank?
      html << hidden_field_tag("CUST_FIELD1",     self.cust_field1)     unless self.cust_field1.blank?
      html << hidden_field_tag("CUST_FIELD2",     self.cust_field2)     unless self.cust_field2.blank?
      html << hidden_field_tag("CUST_FIELD3",     self.cust_field3)     unless self.cust_field3.blank?
      html << hidden_field_tag("CUST_FIELD4",     self.cust_field4)     unless self.cust_field4.blank?
      html << hidden_field_tag("CUST_FIELD5",     self.cust_field5)     unless self.cust_field5.blank?
      html << "<input type=\"hidden\" name=\"NEW_ITEM-LONGTEXT_#{index + 1}:132[]\" value=\"#{escape_html(self.longtext)}\" />" unless self.longtext.blank?
      html.join
    end
    
  private
    
    def hidden_field_tag(name, value, options = {})
      "<input type=\"hidden\" name=\"NEW_ITEM-#{name}[#{index + 1}]\" value=\"#{escape_html(value)}\" />"
    end
    
    ESCAPE_HTML	=	{ "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", "'" => "&#39;", '"' => "&quot;", }
    ESCAPE_HTML_PATTERN	=	Regexp.union(ESCAPE_HTML.keys)

    # Shamelessly borrowed from Rack::Utils.escape_html(s)
    def escape_html(s)
      s.to_s.gsub(ESCAPE_HTML_PATTERN){|c| ESCAPE_HTML[c] }
    end

  end
end
