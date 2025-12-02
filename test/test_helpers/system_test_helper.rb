module SystemTestHelper
  def sign_in_as(email_address, password: "password")
    visit new_session_path

    fill_in "email_address", with: email_address
    fill_in "password", with: password

    click_on "Sign in"
  end
end
