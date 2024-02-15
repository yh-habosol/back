//authentication part
- 회원가입 하면 해당 유저 정보 Users에 저장 (v)

- 로그인하면 -> 해당 유저 정보 Users에서 가져옴 (v)






///community part
- 게시판 페이지로 이동 -> 해당 페이지에서는 Posts에서 post를 작성 일자 순으로 나열(제목만), 각각은 버튼 (v)

- 각 게시판 게시글 누르면 -> 게시글 세부 페이지로 이동, 글 내용, 댓글 보여야 함 (v)

- 게시글 작성 버튼 누르면 -> title, content, maxNumber 입력하고 생성 버튼 누르기 (v)

- 게시글 -> 로그인 한 유저의 게시글일 경우만 edit, delete 표시 보이기 (v)
- 게시글 올리면 해당 유저의 posts 컬렉션에 해당 post 추가해야 함 (v)
- Posts 컬렉션에 해당 post 추가 (v)


- 좋아요 버튼 누르면 숫자 올라가고 해당 post에 반영 (v)
- join 버튼 누르면 -> 정원 다 차기 전이면 추가되고 참여 인원 수 증가 (v)
- 게시글 생성하면 post에 join_users에 작성한 user id 추가하기 (v)
- 게시글 생성하면 작성한 user에 join_challenge 컬렉션에 해당 post id 추가 (v)

- join 누르면 -> user join_challenge 컬렉션에 해당 post 하나 추가 (v)
- join 버튼 누르면 해당 post에 join_users 컬랙션에 user 추가 (v)


- disjoin 누르면 -> post에서 join_users 컬랙션에 해당 user 삭제    (v)
- 해당 user 안에 join_challenges 컬렉션에서 현재 post id 삭제 (v)

- delete 버튼 누르면 -> post에 join_users에 있는 각 user에 대해 join_challenges에서 해당 post삭제 (v)


- 댓글
    -댓글 달기 (v)
    -댓글 단 유저와 로그인한 유저 같으면 edit, delete버튼 보이게 하기 (v)



- location 정보 가져와서 저정도 해야함 ()
- 지도 페이지 -> 현재 내 위치 좌표 기준 반경 몇 미터 이내 좌표 게시물 목록 나열 ()
- 회원정보 수정 -> profile image 설정 ()








///challenge part
///레벨업 하면 뭐 추가해야되는지 아직 잘 몰라서 이부부은 얘기하고 추가해야 함//////////////////////////////////////////////////////////////////////////////


버튼 누르면 -> daily challenge 5개 랜덤으로 추출 (v)
random challenge 화면에 출력 (v)
각 challenge의 content와, 옆에 체크 박스가 있음
매일 아침 6시가 되면 모든 user의 daily challenge는 []가 됨 -> 이런 식으로 구현할 지? 만약 이렇게 구현한다면 플랫폼마다 시간 체크하는 방법이 다르다고 해서 상의하고 결정


체크박스 체크하면, 체크 해제하면
-> 


exp는 변화할 때마다 exp가 10이 되면, level +1 하고, exp 다시 0으로 바꿈


월별 결과, 일별 결과를 봐야 함 
 - 그냥 오늘 일 구한 다음 done_challenge에서 해당 일 찾는걸로
 - 월별은 분류가 월 단위니까 그냥 해당 월 done challenge 개수 세면 됨


community challenge done 하면 
해당 post done 처리, 해당 post에 있는 각각의 join_user들에 대해 join_challenge에서 해당 
post id 제거, 해당 월 done_challenge post id 추가, exp 1 추가

daily challenge done 하면 exp 1 추가, done challenge에 추가, 
daily challenge에서 해당 challenge 제거 
