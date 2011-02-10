# encoding: utf-8

require 'sapoci'
require 'sapoci/document'
require 'test/unit'

class TestOutput < Test::Unit::TestCase
  include SAPOCI
  
  def test_edge_cases
    assert_equal "", Document.from_params(nil).to_html
    assert_equal "", Document.from_params({}).to_html
    assert_equal "", Document.from_params({"TEST" => "VALUE"}).to_html
  end

  def test_simple_output
    params = { "NEW_ITEM-DESCRIPTION"=>{"1"=>"Description 1"} }
    Document.from_params(params) do |doc|
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[1\]" value="Description 1"/, doc.to_html
    end
  end

  def test_escaped_output
    params = { "NEW_ITEM-DESCRIPTION"=>{"1"=>"Apple iMac\""} }
    Document.from_params(params) do |doc|
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[1\]" value="Apple iMac&quot;"/, doc.to_html
    end
  end

  def test_complex_output
    Document.from_params(valid_params_complex) do |doc|
      html = doc.to_html
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[1\]" value="Visitenkarten"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-CURRENCY\[1\]" value="EUR"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-PRICE\[1\]" value="00000000016\.180"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-LONGTEXT_1:132\[\]" value="Standard Visitenkarte deutsch 200 St. "/, html
    end
  end

  def test_output_non_array_longtext
    # INVALID: NEW_ITEM-LONGTEXT_1:132  (No square brackets!)
    params = { "NEW_ITEM-LONGTEXT_1:132" => "Standard Visitenkarte deutsch 200 St. " }
    Document.from_params(params) do |doc|
      html = doc.to_html
      assert_match /<input type="hidden" name="NEW_ITEM-LONGTEXT_1:132\[\]" value="Standard Visitenkarte deutsch 200 St. "/, html
    end
  end

  def test_output_indexed_longtext
    # INVALID: NEW_ITEM-LONGTEXT_1:132[1]  (Index ist falsch!)
    params = { "NEW_ITEM-LONGTEXT_1:132"=>{"1"=>"Standard Visitenkarte deutsch 200 St. "} }
    Document.from_params(params) do |doc|
      html = doc.to_html
      assert_match /<input type="hidden" name="NEW_ITEM-LONGTEXT_1:132\[\]" value="Standard Visitenkarte deutsch 200 St. "/, html
    end
  end

  def test_output_of_priceunit
    # TEST: NEW_ITEM-PRICEUNIT[1] == "1"
    params = { "NEW_ITEM-PRICEUNIT"=>{"1"=>"1"} }
    Document.from_params(params) do |doc|
      html = doc.to_html
      assert_match /<input type="hidden" name="NEW_ITEM-PRICEUNIT\[1\]" value="1"/, html
    end
  end

  def test_output_correct_index
    params = {
      "NEW_ITEM-DESCRIPTION"=>{
        "1"=>"PRITT COMPACT KORREKTURROLLER 4,2MMX8,5M",
        "2"=>"BX100 SIGEL DP461 BRIEFPAP.IMPRESSIONS",
        "3"=>"BX250 IDEM 92100910721 SD-PAP. A4 WSGE",
        "4"=>"BX150 HP CG965A FARBLASERPAPIER A4 150G"
      },
      "NEW_ITEM-LONGTEXT_2:132"=>["Briefpapier Sigel DP461, Impressions, 100 Blatt"],
      "NEW_ITEM-CURRENCY"=>{"1"=>"EUR", "2"=>"EUR", "3"=>"EUR", "4"=>"USD"},
      "NEW_ITEM-LEADTIME"=>{"1"=>"1", "2"=>"1", "3"=>"1", "4"=>"1"
      },
      "NEW_ITEM-LONGTEXT_3:132"=>["Durchschreibepapapier Idem 2fach, weiß/gelb, 250 Blatt"],
      "NEW_ITEM-LONGTEXT_1:132"=>["Korrekturroller Pritt Compact Länge 8.5m Breite 4.2mm für Gedrucktes"],
      "NEW_ITEM-LONGTEXT_4:132"=>["Fotopapier HP CG965A beidseitig beschichtet A4 hochglanz 150g/qm 150 Blatt"],
      "NEW_ITEM-EXT_PRODUCT_ID"=>{
        "1"=>"124474#ST",
        "2"=>"4938724#ST",
        "3"=>"4678213#ST",
        "4"=>"4567185#ST"
      },
      "NEW_ITEM-MATGROUP"=>{"1"=>"24110202", "2"=>"24110534", "3"=>"24110534", "4"=>"24140301"},
      "NEW_ITEM-PRICE"=>{"1"=>"1.440", "2"=>"8.470", "3"=>"18.400", "4"=>"25.740"},
      "NEW_ITEM-PRICEUNIT"=>{"1"=>"1", "2"=>"1", "3"=>"1", "4"=>"1"},
      "NEW_ITEM-VENDORMAT"=>{"1"=>"124474", "2"=>"4938724", "3"=>"4678213", "4"=>"4567185"},
      "NEW_ITEM-QUANTITY"=>{"1"=>"1.000", "2"=>"1.000", "3"=>"1.000", "4"=>"1.000"},
      "NEW_ITEM-UNIT"=>{"1"=>"PCE", "2"=>"PCE", "3"=>"PCE", "4"=>"PCE"}
    }
    Document.from_params(params) do |doc|
      html = doc.to_html
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[1\]" value="PRITT COMPACT KORREKTURROLLER 4,2MMX8,5M"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-CURRENCY\[1\]" value="EUR"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-PRICE\[1\]" value="00000000001\.440"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[2\]" value="BX100 SIGEL DP461 BRIEFPAP.IMPRESSIONS"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-CURRENCY\[2\]" value="EUR"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-PRICE\[2\]" value="00000000008\.470"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[3\]" value="BX250 IDEM 92100910721 SD-PAP. A4 WSGE"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-CURRENCY\[3\]" value="EUR"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-PRICE\[3\]" value="00000000018\.400"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-DESCRIPTION\[4\]" value="BX150 HP CG965A FARBLASERPAPIER A4 150G"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-CURRENCY\[4\]" value="USD"/, html
      assert_match /<input type="hidden" name="NEW_ITEM-PRICE\[4\]" value="00000000025\.740"/, html
    end
  end

private

  def valid_params_complex
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
