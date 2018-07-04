### movie - user cafe 제작하기
* 모델
    - 유저는 여러 영화를 등록할 수 있다. 한 영화는 한 명의 유저에 의해 작성된다.(1:n 관계)
    - 유저는 좋아요를 많이 누를 수 있고, 한 영화는 많은 좋아요를 받는다.
* 컨트롤러
    - user : devise로 구현(`gem 'devise'` 필요)
        - `rails generate devise:install`로 devise를 설치한다.
        - `rails g devise Model`로 만들 수 있다.
    - movie
        - scaffold로 구현해보았다.
* 구현기능
    - 좋아요(ajax사용)
        * 작동 
            - 특정 글에서 영화에 대한 좋아요를 누를 수 있고 눌렀으면 해당 내용을 표시하며, 누른 후에는 좋아요 취소 버튼을 보여준다.
            - route : like를 눌렀을 때 요청보내는 url등을 작성
        * 로직
            - 좋아요 버튼을 눌렀을 경우, 서버에 요청
                > 현재 유저가 현재 보고 있는 이 영화가 좋다고 하는 요청
            
            - 서버는 응답이 오면 좋아요 버튼의 텍스트를 좋아요 취소로 바꾸고, `btn-info` -> `btn-warning text-white`로 변경한다. 
            - 이미 좋아요가 눌러진 경우
        * 모델
            - `rails g model like`
            - 한 유저는 여러 like를 누를 수 있으며, 하나의 영화는 여러 like를 받을 수 있다.
            - 여기서 문제는, 한 작성자의 경우 movie에 대한 글을 작성했을 수가 있다. 따라서, 1:n과 m:n이 동시에 존재할 수 있다.
                > 방법 : 1:n관계를 끊고 like는 직접 has_many를 통해 1:n으로 연결하고, movies는 like를 통해 연결하는 것(through)
            
            - like.rb : `belongs_to :user    belongs_to :movie` -> user와 movie에 종속된다.
            - user.rb : `has_many :likes     has_many :movies, through: :likes` -> 좋아요를 많이 누를 수 있으며, 여러 영화를 작성할 수 있다. 충돌 방지를 위해 관계 하나를 끊고 이어준다.
            - movie.rb : `has_many :likes` -> 많은 수의 좋아요를 가질 수 있다.
        * 컨트롤러
            - 좋아요가 눌러져 서버에 요청이 왔을 때, Like를 새로 생성 : `Like.create(...)`
            - 로그인 하지 않았을 때, 좋아요를 누를 수 없도록 하거나, 로그인하도록 요구해야 한다.
                > 이를 위해서 application_controller에 js_authenticate_user!를 작성하여 로그인 요구한다.
                
                > `render js: "location.href='/users/sign_in';" unless user_signed_in?` : render를 통해 직접 js 코드를 작성할 수 있고 요청을 이로 응답시킬 수 있다.
        * js.erb
            - 좋아요가 눌러졌을 때 이벤트를 수행하는 코드
            - 좋아요를 눌렀을 때, 취소 버튼으로 바꾸며, 취소되었을 때, 버튼 색상 변경
            - toggleClass를 통해서 class를 변경시킬 수 있다.
        * 구현
            - <pre><code>
                <script type="text/javascript">
                    $(document).on('ready', function(){
                        $('.like').on('click', function(){
                            console.log("Like!!");
                            $.ajax({
                                url: '/likes/<%= @movie.id %>'
                            });
                        });
                        
                    });
                </script>
            </code></pre>