# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  def kakao
    redirect_to "https://kauth.kakao.com/oauth/authorize?client_id=#{ENV['KAKAO_REST_API_KEY']}&redirect_uri=http://my-second-rails-app-jwhong1991.c9users.io/users/auth/kakao/callback&response_type=code"
  end
  
  def kakao_auth
    code = params[:code]
    base_url = "https://kauth.kakao.com/oauth/token"
    # post방식으로 요청. parameter : 요청 보내는 곳, 보낼 parameter
    base_response = RestClient.post(base_url, {grant_type: 'authorization_code',
                                              client_id: ENV['KAKAO_REST_API_KEY'],
                                              redirect_uri: 'http://my-second-rails-app-jwhong1991.c9users.io/users/auth/kakao/callback',
                                              code: code
    })
    
    res = JSON.parse(base_response)
    access_token = res["access_token"]
    
    # REST API 개발가이드/사용자 정보 요청 부분
    info_url = "https://kapi.kakao.com/v2/user/me"
    info_response = RestClient.get(info_url,
                                    Authorization: "Bearer #{access_token}")
                                    
    puts JSON.parse(info_response)
    @user = User.from_omniauth_kakao(JSON.parse(info_response))
    
    if @user.persisted?
      flash[:notice] = "카카오 로그인에 성공했습니다."
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:notice] = "카카오 로그인에 실패했습니다. 재시도 해주십시오"
      redirect_to new_user_session_path
    end
  end
  
  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      p request.env['omniauth.auth']
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end
end
