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
    - Ajax검색 기능
        - 구현
            - keyup event를 통해 `input` 태그에 제목을 입력하면 관련 title을 반환한다.
            - ajax를 통해서 `input` 태그의 class를 찾고 parameter로 해당 내용을 서버로 요청한다.
            - controller에서는 `search_movie` action으로 해당 내용을 찾는다.
            * `search_movie` action
                - 빈 내용을 전달시에는 아무것도 찾을 필요가 없으므로 `empty?`메소드를 통해서 `render nothing: true`를 수행한다.
                - 만약 내용을 전달했을 때에는, `Movie.where("title LIKE ?", "#{params[:q]}%")`를 통해 관련 내용을 검색한다.
    - pagination(kaminari gem)
        - <a href="https://github.com/kaminari/kaminari">참조</a>
        - 간단히 사용할 수 있으며, `bundle install`만 하면 바로 paging 기능을 구현할 수 있다.
        * model(rb파일)
            - *movie.rb*에서는 `paginates_per 숫자`를 통해서 페이지마다 얼마나 보여줄지 pagination을 할 수 있다.
        * controller
            - 컨트롤러에서는 `@movies = Movie.page(params[:page])` 통해서 page를 이용토록 구현한다.
        * view
            - `<%= paginate @movies, theme: 'twitter-bootstrap-4' %>` 이와 같이 특정 객체에 따라 얼마나 paging할지 보여줄 수 있으며, theme도 구현할 수 있다.(bootstrap4-kaminari-views gem 필요)
* summernote 사용(wysiwyg)
    - <a href="https://github.com/summernote/summernote-rails">documenttation</a>
    - 설치 및 import
        - `gem 'summernote-rails', '~> 0.8.10.0'`
            > 이외 bootstrap등은 버젼을 맞추어서 받을 것.
        - stylesheets & javascript
            - `@import 'summernote-bs4'`
            - `//= require summernote/summernote-bs4.min`
            - js2coffee를 통해서 coffee script를 js로 변환 후 *summernote-init.js*를 만들고 저장한다.
                > turbolink말고 ready로 코드 변경. 

            - `//= require summernote-init`를 통해 import
    * view
        - form을 통해 사용한다. 따라서 *_form.html.erb*를 변경한다.
            > `<%= f.text_area :description, 'data-provider': :summernote %>` 와 같이 지정
            
            > 참고로 text_area로 사용해야함.
        
        - 바로 editor를 사용할 수 있다. image도 바로 drag and drop이 가능하나 실제 코드를 보면 매우 복잡하다. 따라서 이를 조정해야 한다.
    * image upload to server
        - <a href="https://github.com/summernote/summernote-rails/wiki/Image-File-Upload-to-Server">documentation</a>
        - documentation에서 image upload coffee 코드를 js코드로 변환하여 필요한 부분을 summernote-init.js에 추가한다.
            - 해당 코드를 잘 살펴보고, 그에 관한 route 및 controller action을 지정해야 한다.
        - image를 저장하는 model 만들기
            - `rails g model images image_path`
        - image uploader 생성
            - `rails g uploader summernote`
                > carrierwave가 설치되어 있어야 한다.
            
            - mount
                - Image.rb : `mount_uploader :image_path, SummernoteUploader`
        - ajax로 데이터를 받아오면 해당 내용이 html tag형태로 보여질 것이다.
        - simple_format을 이용하여 text를 html 형식으로 변환시켜주면 된다.
            - `<p><%= simple_format(@movie.description) %></p>`
    * simple_format
        - <a href="https://apidock.com/rails/ActionView/Helpers/TextHelper/simple_format">documentation</a>
* 관리자 페이지(rails admin)
    * 참조
        - <a href="https://github.com/sferik/rails_admin">documentation</a>
    * 설치
        - `gem 'rails_admin'`
        - `rails g rails_admin:install`
            > prompt가 나옴. admin을 어느 경로로 지정할 것인지.
        
    * 서버실행