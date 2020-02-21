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
    attr_accessor :unit
    attr_accessor :currency
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
    attr_accessor :mps_sage_number
    attr_accessor :mps_sage_contract
    attr_accessor :tax_code
    attr_accessor :sold_by
    attr_accessor :fulfilled_by
    attr_accessor :gtin
    attr_accessor :cust_field1
    attr_accessor :cust_field2
    attr_accessor :cust_field3
    attr_accessor :cust_field4
    attr_accessor :cust_field5
    attr_accessor :cust_field6
    attr_accessor :cust_field7
    attr_accessor :cust_field8
    attr_accessor :cust_field9
    attr_accessor :cust_field10
    attr_accessor :cust_field11
    attr_accessor :cust_field12
    attr_accessor :cust_field13
    attr_accessor :cust_field14
    attr_accessor :cust_field15
    attr_accessor :cust_field16
    attr_accessor :cust_field17
    attr_accessor :cust_field18
    attr_accessor :cust_field19
    attr_accessor :cust_field20
    attr_accessor :cust_field21
    attr_accessor :cust_field22
    attr_accessor :cust_field23
    attr_accessor :cust_field24
    attr_accessor :cust_field25
    attr_accessor :cust_field26
    attr_accessor :cust_field27
    attr_accessor :cust_field28
    attr_accessor :cust_field29
    attr_accessor :cust_field30
    attr_accessor :cust_field31
    attr_accessor :cust_field32
    attr_accessor :cust_field33
    attr_accessor :cust_field34
    attr_accessor :cust_field35
    attr_accessor :cust_field36
    attr_accessor :cust_field37
    attr_accessor :cust_field38
    attr_accessor :cust_field39
    attr_accessor :cust_field40
    attr_accessor :cust_field41
    attr_accessor :cust_field42
    attr_accessor :cust_field43
    attr_accessor :cust_field44
    attr_accessor :cust_field45
    attr_accessor :cust_field46
    attr_accessor :cust_field47
    attr_accessor :cust_field48
    attr_accessor :cust_field49
    attr_accessor :cust_field50

    # Initializes the item.
    def initialize(index)
      @index = index
    end

    def decimal(s)
      if RUBY_VERSION >= '2.5'
        BigDecimal(s)
      else
        BigDecimal.new(s)
      end
    end

    def quantity
      if defined?(@quantity)
        decimal("0#{@quantity.to_s.strip.gsub(/,/,'.')}")
      else
        decimal("0.0")
      end
    end

    def quantity=(value)
      @quantity = value
    end

    def quantity_before_type_cast
      @quantity
    end

    def price
      if defined?(@price)
        decimal("0#{@price.to_s.strip.gsub(/,/,'.')}")
      else
        decimal("0.0")
      end
    end

    def price=(value)
      @price = value
    end

    def price_before_type_cast
      @price
    end

    def priceunit
      if defined?(@priceunit)
        decimal("0#{@priceunit.to_s.strip.gsub(/,/,'.')}").nonzero? || 1
      else
        1
      end
    end

    def priceunit=(value)
      @priceunit = value
    end

    def priceunit_before_type_cast
      @priceunit
    end

    def leadtime
      if defined?(@leadtime) && @leadtime
        @leadtime.to_i
      else
        0
      end
    end

    def leadtime=(value)
      @leadtime = value
    end

    def leadtime_before_type_cast
      @leadtime
    end

    def service?
      self.service == "X"
    end

    def tax_rate
      if defined?(@tax_rate)
        decimal("0#{@tax_rate.to_s.strip.gsub(/,/,'.')}")
      else
        decimal("0.0")
      end
    end

    def tax_rate=(value)
      @tax_rate = value
    end

    def tax_rate_before_type_cast
      @tax_rate
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
      html << hidden_field_tag("MPS_SAGE_NUMBER",   self.mps_sage_number)    unless self.mps_sage_number.blank?
      html << hidden_field_tag("MPS_SAGE_CONTRACT", self.mps_sage_contract)  unless self.mps_sage_contract.blank?
      html << hidden_field_tag("TAX_RATE",        "%.5f" % self.tax_rate)  if self.tax_rate.to_f > 0
      html << hidden_field_tag("TAX_CODE",        self.tax_code)        unless self.tax_code.blank?
      html << hidden_field_tag("SOLD_BY",         self.sold_by)         unless self.sold_by.blank?
      html << hidden_field_tag("FULFILLED_BY",    self.fulfilled_by)    unless self.fulfilled_by.blank?
      html << hidden_field_tag("GTIN",            self.gtin)            unless self.gtin.blank?
      html << hidden_field_tag("CUST_FIELD1",     self.cust_field1)     unless self.cust_field1.blank?
      html << hidden_field_tag("CUST_FIELD2",     self.cust_field2)     unless self.cust_field2.blank?
      html << hidden_field_tag("CUST_FIELD3",     self.cust_field3)     unless self.cust_field3.blank?
      html << hidden_field_tag("CUST_FIELD4",     self.cust_field4)     unless self.cust_field4.blank?
      html << hidden_field_tag("CUST_FIELD5",     self.cust_field5)     unless self.cust_field5.blank?
      html << hidden_field_tag("CUST_FIELD6",     self.cust_field6)     unless self.cust_field6.blank?
      html << hidden_field_tag("CUST_FIELD7",     self.cust_field7)     unless self.cust_field7.blank?
      html << hidden_field_tag("CUST_FIELD8",     self.cust_field8)     unless self.cust_field8.blank?
      html << hidden_field_tag("CUST_FIELD9",     self.cust_field9)     unless self.cust_field9.blank?
      html << hidden_field_tag("CUST_FIELD10",    self.cust_field10)    unless self.cust_field10.blank?
      html << hidden_field_tag("CUST_FIELD11",    self.cust_field11)    unless self.cust_field11.blank?
      html << hidden_field_tag("CUST_FIELD12",    self.cust_field12)    unless self.cust_field12.blank?
      html << hidden_field_tag("CUST_FIELD13",    self.cust_field13)    unless self.cust_field13.blank?
      html << hidden_field_tag("CUST_FIELD14",    self.cust_field14)    unless self.cust_field14.blank?
      html << hidden_field_tag("CUST_FIELD15",    self.cust_field15)    unless self.cust_field15.blank?
      html << hidden_field_tag("CUST_FIELD16",    self.cust_field16)    unless self.cust_field16.blank?
      html << hidden_field_tag("CUST_FIELD17",    self.cust_field17)    unless self.cust_field17.blank?
      html << hidden_field_tag("CUST_FIELD18",    self.cust_field18)    unless self.cust_field18.blank?
      html << hidden_field_tag("CUST_FIELD19",    self.cust_field19)    unless self.cust_field19.blank?
      html << hidden_field_tag("CUST_FIELD20",    self.cust_field20)    unless self.cust_field20.blank?
      html << hidden_field_tag("CUST_FIELD21",    self.cust_field21)    unless self.cust_field21.blank?
      html << hidden_field_tag("CUST_FIELD22",    self.cust_field22)    unless self.cust_field22.blank?
      html << hidden_field_tag("CUST_FIELD23",    self.cust_field23)    unless self.cust_field23.blank?
      html << hidden_field_tag("CUST_FIELD24",    self.cust_field24)    unless self.cust_field24.blank?
      html << hidden_field_tag("CUST_FIELD25",    self.cust_field25)    unless self.cust_field25.blank?
      html << hidden_field_tag("CUST_FIELD26",    self.cust_field26)    unless self.cust_field26.blank?
      html << hidden_field_tag("CUST_FIELD27",    self.cust_field27)    unless self.cust_field27.blank?
      html << hidden_field_tag("CUST_FIELD28",    self.cust_field28)    unless self.cust_field28.blank?
      html << hidden_field_tag("CUST_FIELD29",    self.cust_field29)    unless self.cust_field29.blank?
      html << hidden_field_tag("CUST_FIELD30",    self.cust_field30)    unless self.cust_field30.blank?
      html << hidden_field_tag("CUST_FIELD31",    self.cust_field31)    unless self.cust_field31.blank?
      html << hidden_field_tag("CUST_FIELD32",    self.cust_field32)    unless self.cust_field32.blank?
      html << hidden_field_tag("CUST_FIELD33",    self.cust_field33)    unless self.cust_field33.blank?
      html << hidden_field_tag("CUST_FIELD34",    self.cust_field34)    unless self.cust_field34.blank?
      html << hidden_field_tag("CUST_FIELD35",    self.cust_field35)    unless self.cust_field35.blank?
      html << hidden_field_tag("CUST_FIELD36",    self.cust_field36)    unless self.cust_field36.blank?
      html << hidden_field_tag("CUST_FIELD37",    self.cust_field37)    unless self.cust_field37.blank?
      html << hidden_field_tag("CUST_FIELD38",    self.cust_field38)    unless self.cust_field38.blank?
      html << hidden_field_tag("CUST_FIELD39",    self.cust_field39)    unless self.cust_field39.blank?
      html << hidden_field_tag("CUST_FIELD40",    self.cust_field40)    unless self.cust_field40.blank?
      html << hidden_field_tag("CUST_FIELD41",    self.cust_field41)    unless self.cust_field41.blank?
      html << hidden_field_tag("CUST_FIELD42",    self.cust_field42)    unless self.cust_field42.blank?
      html << hidden_field_tag("CUST_FIELD43",    self.cust_field43)    unless self.cust_field43.blank?
      html << hidden_field_tag("CUST_FIELD44",    self.cust_field44)    unless self.cust_field44.blank?
      html << hidden_field_tag("CUST_FIELD45",    self.cust_field45)    unless self.cust_field45.blank?
      html << hidden_field_tag("CUST_FIELD46",    self.cust_field46)    unless self.cust_field46.blank?
      html << hidden_field_tag("CUST_FIELD47",    self.cust_field47)    unless self.cust_field47.blank?
      html << hidden_field_tag("CUST_FIELD48",    self.cust_field48)    unless self.cust_field48.blank?
      html << hidden_field_tag("CUST_FIELD49",    self.cust_field49)    unless self.cust_field49.blank?
      html << hidden_field_tag("CUST_FIELD50",    self.cust_field50)    unless self.cust_field50.blank?
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
