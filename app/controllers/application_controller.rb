class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def js_authenticate_user!
      # 직접 js code 작성할 수 있다.
      render js: "location.href='/users/sign_in';" unless user_signed_in?
  end
end
