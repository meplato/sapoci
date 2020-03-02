# encoding: utf-8

require 'sapoci'
require 'sapoci/document'
require 'test/unit'

class TestParse < Test::Unit::TestCase
  include SAPOCI

  def test_parse_html
    Document.from_html(valid_single_html) do |doc|
      count = 0
      doc.items.each do |item|
        assert_equal "Description 1", item.description
        count += 1
      end
      assert_equal 1, count
    end
  end

  def test_parse_long_html
    Document.from_html(valid_long_html) do |doc|
      assert_equal 2, doc.items.count
      assert_equal "Apple MacBook Air 11\"", doc.items[0].description
      assert_equal "Ein tolles Notebook von Apple.", doc.items[0].longtext
      assert_equal nil, doc.items[0].service
      assert_equal false, doc.items[0].service?
      assert_equal "2000111096426", doc.items[0].gtin
      assert_equal "Apple iMac 27\"", doc.items[1].description
      assert_equal "Der elegante Desktop-Rechner von Apple.", doc.items[1].longtext
      assert_equal "X", doc.items[1].service
      assert_equal true, doc.items[1].service?
      assert_equal "4060838384365", doc.items[1].gtin
    end
  end

  def test_parse_invalid_longtext_html
    Document.from_html(valid_invalid_longtext_html) do |doc|
      assert_equal 5, doc.items.count
      assert_equal "Apple MacBook Air 11\"", doc.items[0].description
      assert_equal "Apple iMac 27\"", doc.items[1].description
      assert_equal "Apple iMac 27 Pro\"", doc.items[2].description
      assert_equal "Apple iPad 10.5\"", doc.items[3].description
      assert_equal "Apple iPhone 7 Plus", doc.items[4].description
      assert_equal "Ein tolles Notebook von Apple.", doc.items[0].longtext
      assert_equal "Der elegante Desktop-Rechner von Apple.", doc.items[1].longtext
      assert_equal "Der Profi-Rechner von Apple.", doc.items[2].longtext
      assert_equal "Das Pro Tablet von Apple.", doc.items[3].longtext
      assert_equal "Das iPhone 7 Plus. Weil größer ist besser.", doc.items[4].longtext
    end
  end

  def test_parse_real_world
    file = File.expand_path(File.dirname(__FILE__) + "/files/real_world.html")
    Document.from_html(IO.read(file)) do |doc|
      count = 0
      doc.items.each do |item|
        assert !item.description.blank?
        count += 1
      end
      assert_equal 10, count
    end
  end

  def test_parse_params
    Document.from_params(valid_single_params) do |doc|
      count = 0
      doc.items.each do |item|
        assert_equal "Visitenkarten", item.description
        assert_equal "Standard Visitenkarte deutsch 200 St. ", item.longtext
        assert_equal 16.18, item.price
        count += 1
      end
      assert_equal 1, count
    end
  end

  def test_parse_invalid_longtext_params
    params = {
      "NEW_ITEM-DESCRIPTION"=>{
        "1"=>"Position 1",
        "2"=>"Position 2",
        "3"=>"Position 3",
        "4"=>"Position 4",
      },
      "NEW_ITEM-LONGTEXT"=>{
        "1"=>"Langtext 1"
      },
      "NEW_ITEM-LONGTEXT_2:132"=>{
        "2"=>"Langtext 2",
      },
      "NEW_ITEM-LONGTEXT_3:132"=>[
        "Langtext 3",
      ],
      # Completely broken...
      "NEW_ITEM-LONGTEXT_4:132"=>[{
        "4"=>"Langtext 4",
      }],
      # "NEW_ITEM-LONGTEXT_1:132"=>[{"1"=>"Zeskantbout ISO 4014 Staal Rechts Blank 8.8 M16X160"}]
    }
    Document.from_params(params) do |doc|
      assert_equal 4, doc.items.size
      assert_equal "Position 1", doc.items[0].description
      assert_equal "Langtext 1", doc.items[0].longtext
      assert_equal "Position 2", doc.items[1].description
      assert_equal "Langtext 2", doc.items[1].longtext
      assert_equal "Position 3", doc.items[2].description
      assert_equal "Langtext 3", doc.items[2].longtext
      assert_equal "Position 4", doc.items[3].description
      assert_equal "Langtext 4", doc.items[3].longtext
    end
  end

  def test_parse_meplato_extensions
    file = File.expand_path(File.dirname(__FILE__) + "/files/meplato_extensions.html")
    Document.from_html(IO.read(file)) do |doc|
      count = 0
      doc.items.each do |item|
        assert !item.mps_sage_number.blank?
        assert !item.mps_sage_contract.blank?
        assert !item.cust_field30.blank?
        assert_equal 0.19, item.tax_rate
        assert !item.tax_code.blank?
        assert !item.sold_by.blank?
        assert !item.fulfilled_by.blank?
        count += 1
      end
      assert_equal 10, count
    end
  end

  def test_ignore_unknown_fields
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-TAX_RATE"=>{"1"=>"0.19"},  # <= no such property in OCI
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>"100 "},  # <= watch the whitespace
      "NEW_ITEM-QUANTITY"=>{"1"=>" 12 "},  # <= watch the whitespace
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 100.00, item.priceunit
      assert_equal 12, item.quantity
    end
  end

  def test_ignore_whitespace_on_numeric_fields
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-PRICE"=>{"1"=>" 780.00"},  # <= watch the whitespace
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>"100 "},  # <= watch the whitespace
      "NEW_ITEM-QUANTITY"=>{"1"=>" 12 "},  # <= watch the whitespace
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 780.00, item.price
      assert_equal 100.00, item.priceunit
      assert_equal 12, item.quantity
    end
  end

  def test_parse_numeric_fields_with_comma
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-PRICE"=>{"1"=>" 780,12"},  # <= watch the whitespace and the comma
      "NEW_ITEM-TAX_RATE"=>{"1"=>" 0,19"},  # <= watch the whitespace and the comma
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 780.12, item.price
      assert_equal 0.19, item.tax_rate
    end
  end

  def test_return_1_if_priceunit_is_missing
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-PRICE"=>{"1"=>"780.00"},
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 1, item.priceunit
    end
  end

  def test_return_1_if_priceunit_is_empty
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-PRICE"=>{"1"=>"780.00"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>""},  # <= watch the blanks
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 1, item.priceunit
    end
  end

  def test_return_1_if_priceunit_is_all_whitespace
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-PRICE"=>{"1"=>"780.00"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>" "},  # <= watch the whitespace
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 1, item.priceunit
    end
  end

  def test_before_type_cast_methods
    params = {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-PRICE"=>{"1"=>" 780.00"},  # <= watch the whitespace
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>"100 "},  # <= watch the whitespace
      "NEW_ITEM-QUANTITY"=>{"1"=>" 12 "},  # <= watch the whitespace
    }
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert item = doc.items.first
      assert_equal 780.00, item.price
      assert_equal " 780.00", item.price_before_type_cast
      assert_equal 100.00, item.priceunit
      assert_equal "100 ", item.priceunit_before_type_cast
      assert_equal 12, item.quantity
      assert_equal " 12 ", item.quantity_before_type_cast
    end
  end

  def test_parse_non_array_longtext
    # INVALID: NEW_ITEM-LONGTEXT_1:132  (No square brackets!)
    params = valid_single_params
    params["NEW_ITEM-LONGTEXT_1:132"] = "Standard Visitenkarte deutsch 200 St. "
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert_equal "Standard Visitenkarte deutsch 200 St. ", doc.items[0].longtext
    end
  end

  def test_parse_array_longtext
    # INVALID: NEW_ITEM-LONGTEXT_1:132[]
    params = valid_single_params
    params["NEW_ITEM-LONGTEXT_1:132"] = ["Standard Visitenkarte deutsch 200 St. "]
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert_equal "Standard Visitenkarte deutsch 200 St. ", doc.items[0].longtext
    end
  end

  def test_parse_indexed_longtext
    # INVALID: NEW_ITEM-LONGTEXT_1:132[1]  (Index ist falsch!)
    params = valid_single_params
    params["NEW_ITEM-LONGTEXT_1:132"] = {"1"=>"Standard Visitenkarte deutsch 200 St. "}
    Document.from_params(params) do |doc|
      assert_equal 1, doc.items.size
      assert_equal "Standard Visitenkarte deutsch 200 St. ", doc.items[0].longtext
    end
  end

  def test_parse_order
    Document.from_html(valid_multiple_html) do |doc|
      assert_equal 3, doc.items.size
      assert_equal 0, doc.items[0].index
      assert_equal "Description 1", doc.items[0].description
      assert_equal 1, doc.items[1].index
      assert_equal "Description 2", doc.items[1].description
      assert_equal 2, doc.items[2].index
      assert_equal "Description 3", doc.items[2].description
    end
  end

  # Will parse data according to POSITION specified by input,
  # regardless of holes.
  def test_parse_invalid_order
    html = <<EOF
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[1]' value='Description 1'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[3]' value='Description 3'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[4]' value='Description 4'>
EOF
    Document.from_html(html) do |doc|
      assert_equal 3, doc.items.size
      assert_equal 0, doc.items[0].index
      assert_equal "Description 1", doc.items[0].description
      assert_equal 2, doc.items[1].index
      assert_equal "Description 3", doc.items[1].description
      assert_equal 3, doc.items[2].index
      assert_equal "Description 4", doc.items[2].description
    end
  end

  def test_parse_quotes_from_html
    Document.from_html(valid_html_with_quotes) do |doc|
      count = 0
      doc.items.each do |item|
        assert_equal "19\" Rack", item.description
        count += 1
      end
      assert_equal 1, count
    end
  end

  def test_strip_quotes_for_invalid_input
    # Notice the quote in the value attributes
    html = '<input type="hidden" name="NEW_ITEM-DESCRIPTION[1]" value="19" Rack">'
    Document.from_html(html) do |doc|
      assert_equal 1, doc.items.count
      assert_equal "19", doc.items[0].description
    end
  end

private

  def valid_single_html
<<EOF
<html>
  <head>
    <title>OCI Data</title>
  </head>
  <body>
    <form method='POST' action='http://punchout.local/punchback'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[1]' value='Description 1'>
    </form>
  </body>
</html>
EOF
  end

  def valid_multiple_html
<<EOF
<html>
  <head>
    <title>OCI Data</title>
  </head>
  <body>
    <form method='POST' action='http://punchout.local/punchback'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[2]' value='Description 2'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[3]' value='Description 3'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[1]' value='Description 1'>
    </form>
  </body>
</html>
EOF
  end

  def valid_long_html
<<EOF
<html>
  <head><title>Search1</title></head>
  <body>
    <form method="POST" action="http://return.to/me">
      <input type="hidden" name="NEW_ITEM-DESCRIPTION[1]" value="Apple MacBook Air 11&quot;">
      <input type="hidden" name="NEW_ITEM-QUANTITY[1]" value="1.00">
      <input type="hidden" name="NEW_ITEM-UNIT[1]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[1]" value="999.90">
      <input type="hidden" name="NEW_ITEM-CURRENCY[1]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[1]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[1]" value="7">
      <input type="hidden" name="NEW_ITEM-VENDOR[1]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[1]" value="MBA11">
      <input type="hidden" name="NEW_ITEM-MATGROUP[1]" value="NOTEBOOK">
      <input type="hidden" name="NEW_ITEM-LONGTEXT_1:132[]" value="Ein tolles Notebook von Apple.">
      <input type="hidden" name="NEW_ITEM-GTIN[1]" value="2000111096426">
      
      <input type="hidden" name="NEW_ITEM-DESCRIPTION[2]" value="Apple iMac 27&quot;">
      <input type="hidden" name="NEW_ITEM-QUANTITY[2]" value="2.00">
      <input type="hidden" name="NEW_ITEM-UNIT[2]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[2]" value="1799.00">
      <input type="hidden" name="NEW_ITEM-CURRENCY[2]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[2]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[2]" value="7">
      <input type="hidden" name="NEW_ITEM-SERVICE[2]" value="X">
      <input type="hidden" name="NEW_ITEM-VENDOR[2]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[2]" value="IMAC27">
      <input type="hidden" name="NEW_ITEM-MATGROUP[2]" value="DESKTOP">
      <input type="hidden" name="NEW_ITEM-LONGTEXT_2:132[]" value="Der elegante Desktop-Rechner von Apple.">
      <input type="hidden" name="NEW_ITEM-GTIN[2]" value="4060838384365">
    </form>
  </body>
</html>
EOF
  end

  def valid_html_with_quotes
<<EOF
<html>
  <head>
    <title>OCI Data</title>
  </head>
  <body>
    <form method='POST' action='http://punchout.local/punchback'>
      <input type='hidden' name='NEW_ITEM-DESCRIPTION[1]' value='19" Rack'>
    </form>
  </body>
</html>
EOF
  end

  def valid_invalid_longtext_html
<<EOF
<html>
  <head><title>Search1</title></head>
  <body>
    <form method="POST" action="http://return.to/me">
      <input type="hidden" name="NEW_ITEM-DESCRIPTION[1]" value="Apple MacBook Air 11&quot;">
      <input type="hidden" name="NEW_ITEM-QUANTITY[1]" value="1.00">
      <input type="hidden" name="NEW_ITEM-UNIT[1]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[1]" value="999.90">
      <input type="hidden" name="NEW_ITEM-CURRENCY[1]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[1]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[1]" value="7">
      <input type="hidden" name="NEW_ITEM-VENDOR[1]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[1]" value="MBA11">
      <input type="hidden" name="NEW_ITEM-MATGROUP[1]" value="NOTEBOOK">
      <!-- Correct according to spec -->
      <input type="hidden" name="NEW_ITEM-LONGTEXT_1:132[]" value="Ein tolles Notebook von Apple.">

      <input type="hidden" name="NEW_ITEM-DESCRIPTION[2]" value="Apple iMac 27&quot;">
      <input type="hidden" name="NEW_ITEM-QUANTITY[2]" value="2.00">
      <input type="hidden" name="NEW_ITEM-UNIT[2]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[2]" value="1799.00">
      <input type="hidden" name="NEW_ITEM-CURRENCY[2]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[2]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[2]" value="7">
      <input type="hidden" name="NEW_ITEM-VENDOR[2]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[2]" value="IMAC27">
      <input type="hidden" name="NEW_ITEM-MATGROUP[2]" value="DESKTOP">
      <!-- Incorrect: Index in brackets -->
      <input type="hidden" name="NEW_ITEM-LONGTEXT_2:132[2]" value="Der elegante Desktop-Rechner von Apple.">

      <input type="hidden" name="NEW_ITEM-DESCRIPTION[3]" value="Apple iMac 27 Pro&quot;">
      <input type="hidden" name="NEW_ITEM-QUANTITY[3]" value="1.00">
      <input type="hidden" name="NEW_ITEM-UNIT[3]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[3]" value="4999.00">
      <input type="hidden" name="NEW_ITEM-CURRENCY[3]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[3]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[3]" value="14">
      <input type="hidden" name="NEW_ITEM-VENDOR[3]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[3]" value="IMAC27PRO">
      <input type="hidden" name="NEW_ITEM-MATGROUP[3]" value="SERVER">
      <!-- Incorrect: Index in brackets plus incorrect field name -->
      <input type="hidden" name="NEW_ITEM-LONGTEXT:132[3]" value="Der Profi-Rechner von Apple.">

      <input type="hidden" name="NEW_ITEM-DESCRIPTION[4]" value="Apple iPad 10.5&quot;">
      <input type="hidden" name="NEW_ITEM-QUANTITY[4]" value="1.00">
      <input type="hidden" name="NEW_ITEM-UNIT[4]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[4]" value="799.00">
      <input type="hidden" name="NEW_ITEM-CURRENCY[4]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[4]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[4]" value="3">
      <input type="hidden" name="NEW_ITEM-VENDOR[4]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[4]" value="IPADPRO10/5">
      <input type="hidden" name="NEW_ITEM-MATGROUP[4]" value="TABLET">
      <!-- Incorrect: Index in brackets plus even more incorrect field name -->
      <input type="hidden" name="NEW_ITEM-LONGTEXT[4]" value="Das Pro Tablet von Apple.">

      <input type="hidden" name="NEW_ITEM-DESCRIPTION[5]" value="Apple iPhone 7 Plus">
      <input type="hidden" name="NEW_ITEM-QUANTITY[5]" value="1.00">
      <input type="hidden" name="NEW_ITEM-UNIT[5]" value="PCE">
      <input type="hidden" name="NEW_ITEM-PRICE[5]" value="899.00">
      <input type="hidden" name="NEW_ITEM-CURRENCY[5]" value="EUR">
      <input type="hidden" name="NEW_ITEM-PRICEUNIT[5]" value="1">
      <input type="hidden" name="NEW_ITEM-LEADTIME[5]" value="3">
      <input type="hidden" name="NEW_ITEM-VENDOR[5]" value="Apple">
      <input type="hidden" name="NEW_ITEM-VENDORMAT[5]" value="IPHONE7+">
      <input type="hidden" name="NEW_ITEM-MATGROUP[5]" value="MOBILE">
      <!-- Incorrect: Like... completely broken... -->
      <input type="hidden" name="NEW_ITEM-LONGTEXT_5:132[][5]" value="Das iPhone 7 Plus. Weil größer ist besser.">
    </form>
  </body>
</html>
EOF
  end

  def valid_single_params
    {
      "NEW_ITEM-DESCRIPTION"=>{"1"=>"Visitenkarten"},
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR"},
      "NEW_ITEM-CUST_FIELD1"=>{"1"=>""},
      "NEW_ITEM-CUST_FIELD2"=>{"1"=>""},
      "NEW_ITEM-CUST_FIELD3"=>{"1"=>""},
      "NEW_ITEM-LEADTIME"=>{"1"=>"10"},
      "NEW_ITEM-MANUFACTCODE"=>{"1"=>""},
      "NEW_ITEM-SERVICE"=>{"1"=>""},
      "NEW_ITEM-EXT_PRODUCT_ID"=>{"1"=>""},
      "NEW_ITEM-CUST_FIELD4"=>{"1"=>""},
      "NEW_ITEM-CONTRACT_ITEM"=>{"1"=>""},
      "NEW_ITEM-EXT_QUOTE_ID"=>{"1"=>""},
      "NEW_ITEM-LONGTEXT_1:132"=>["Standard Visitenkarte deutsch 200 St. "],
      "NEW_ITEM-CUST_FIELD5"=>{"1"=>""},
      "NEW_ITEM-QUANTITY"=>{"1"=>"1"},
      "NEW_ITEM-CONTRACT"=>{"1"=>""},
      "NEW_ITEM-PRICE"=>{"1"=>"16.18"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>""},
      "NEW_ITEM-VENDOR"=>{"1"=>"9999"},
      "NEW_ITEM-VENDORMAT"=>{"1"=>"1517"},
      "NEW_ITEM-MATGROUP"=>{"1"=>"24-26-09-01"},
      "NEW_ITEM-MANUFACTMAT"=>{"1"=>""},
      "NEW_ITEM-EXT_QUOTE_ITEM"=>{"1"=>""},
      "NEW_ITEM-MATNR"=>{"1"=>""},
      "NEW_ITEM-UNIT"=>{"1"=>"EA"}
    }
  end

end
