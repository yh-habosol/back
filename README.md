To Do List


회원가입 하면 해당 유저 정보 Users에 저장 (v)



로그인하면 -> 해당 유저 정보 Users에서 가져옴 (v)



게시판 페이지로 이동 -> 해당 페이지에서는 Posts에서 post를 
		        작성 일자 순으로 나열(제목만), 각각은 버튼 (v)



각 게시판 게시글 누르면 -> 게시글 세부 페이지로 이동, 글 내용, 댓글 보여야 함 (v)



게시글 작성 버튼 누르면 -> title, content, maxNumber 입력하고 생성 버튼 누르기 (v)



게시글 -> 로그인 한 유저의 게시글일 경우만 edit, delete 표시 보이기 (v)
	 게시글 올리면 해당 유저의 posts 컬렉션에 해당 post 추가해야 함 (v)
	 Posts 컬렉션에 해당 post 추가 (v)




///게시글 CRUD 과제
- 수정이나 삭제 후 새로고침 해야 반영되는 문제
- location 정보 가져와서 저정도 해야함
- 좋아요 버튼 누르면 숫자 올라가고 해당 post에 반영 (v)
- join 버튼 누르면 -> 정원 다 차기 전이면 추가되고 참여 인원 수 증가 (v)
- join 누르면 -> user join_challenge 컬렉션에 해당 post 하나 추가
- join 버튼 누르면 해당 post에 join_users 컬랙션에 user 추가
- delete 버튼 누르면 -> post에 join_users에 있는 각 user에 대해 join_challenge에서 해당 post
		      삭제
- 댓글
    -댓글 달기
    -댓글 단 유저와 로그인한 유저 같으면 edit, delete버튼 보이게 하기






지도 페이지 -> 현재 내 위치 좌표 기준 반경 몇 미터 이내 좌표 게시물 목록 나열 ()



회원정보 수정 -> profile image 설정 ()