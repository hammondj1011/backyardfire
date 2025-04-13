require "test_helper"

class QrCodeControllerTest < ActionDispatch::IntegrationTest
  test "show renders a QR code as a cacheable SVG image" do
    id = Base64.urlsafe_encode64("http://example.com")

    get qr_code_path(id)

    assert_response :success
    assert_includes response.content_type, "image/svg+xml"

    assert_equal 1.year, response.cache_control[:max_age].to_i
    assert response.cache_control[:public]
  end
end
