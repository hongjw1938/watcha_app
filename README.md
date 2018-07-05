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
        * String interpolation
            - <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals">참조</a>
            - like_movie.js.erb파일에 사용
    - 댓글
        * cf) html에서 태그에 data-id라는 방식으로 속성을 주면 data-* 에 의해서 데이터 method를 사용가능하다.
            - <a href="https://www.w3schools.com/tags/att_global_data.asp">참조</a>
        * 기능
            - form(요소)이 제출(이벤트)될 때(이벤트 리스너), input(요소)안의 내용물(요소)을 받아서 ajax요청으로 서버에 요청
            - 보낼 때에는 내용물, 현재 보고있는 movie의 id 값도 같이 보낸다.
            - 서버에서 저장하고, response 보내줄 js.erb 파일을 작성
            - 댓글에 있는 삭제 버튼(요소)를 누르면(이벤트 리스너) 해당 댓글이 눈에 안보이며(이벤트 핸들러), 실제 db에서도 삭제된다.
                > 문제는, ajax로 댓글을 새로 작성시에 dom트리를 새로 그리지 않기 때문에 해당 댓글은 즉각적인 삭제가 안된다.
                
                > 따라서, `$(document).on('click', 'destroy-comment', function(){});` 와 같이 추가하여 리소스를 잡아먹더라도 돔 트리를 다시 그리도록 만들어야 한다.
            
            * 수정
                - 수정 버튼을 클릭시에, 댓글이 있던 부분이 입력창으로 바뀌면서 원 댓글의 내용이 입력창에 들어간다.
                - 수정 버튼은 수정 완료 확인버튼으로 바뀐다.
                - 내용 수정 후 확인 버튼을 클릭하면 입력창이 댓글의 원래 형태로 바뀐다.
                - 확인버튼은 다시 수정버튼으로 변경된다.
                - 입력창에 있던 내용물을 ajax로 서버에 요청보내고 서버에서는 해당 댓글을 찾아 내용을 업데이트 한다.
                - 전체 문서에서 update-comment 클래스를 가진 버튼이 있다면 더이상 진행하지 않고 이벤트 핸들러를 종료함.(`return`)
        * nested routing(<a href="http://guides.rubyonrails.org/routing.html#nested-resources">nested resources</a>)
            - resources안에 또 다시 route를 지정할 수 있다.
            - member / collection
                - member를 사용할 경우 :id 부분에 자동으로 세팅됨.
                - <pre><code>
                    resources :movies do
                        member do
                          post '/comments' => 'movies#create_comment'
                          # post '/likes/:movie_id/comments' => 'movies#create_comment' 와 같다.
                        end
                        
                        # collection do
                        #   get '/test' => 'movies#test'
                        # end
                    end
                </code></pre>
        * model
            - `rails g model comment user_id movie_id contents` : user_id와 movie_id는 양 쪽에 종속되기 때문
        * controller
            - create_comment action에서 comment를 생성한다.
        * 