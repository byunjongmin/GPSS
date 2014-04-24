% =========================================================================
%> @section INTRO MakeFlatAreas
%>
%> - 일정한 경사를 가진 평탄면을 만드는 함수
%>  - 임의 경사를 가진 평탄면이란 모델 영역의 남쪽 경계가 고정된 상태에서
%>    북쪽으로 갈수록 임의 경사각만큼 고도가 증가하는 평탄면. 한편 rand함수를
%>    이용하여 지표에 임의의 굴곡을 줄 수 있음
%>  - 동일한 초기 경사각이라도, DX와 Y의 크기에 따라 평탄면의 규모는 큰 차이를 
%>     보임
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval plane        : 임의 경사를 가진 평탄면
%>
%> @param Y             : 외곽 경계를 제외한 Y축 크기
%> @param X             : 외곽 경계를 제외한 X축 크기
%> @param dX            : 셀 크기 [m]
%> @param PLANE_ANGLE   : 임의 경사
% =========================================================================
function plane = MakeFlatAreas(Y,X,dX,PLANE_ANGLE)
%
% function MakeFlatAreas
%

distanceY = Y * dX; % Y 방향 끝 지점 거리
distanceX = X * dX;

% * 주의 : 아래를 고정하고, 상부의 고도를 높게하기 위한 arrayY 만듦.
[tmp,arrayY] = meshgrid(0.5*dX:dX:distanceX-0.5*dX ...
    ,distanceY-0.5*dX:-dX:0.5*dX);

INITIAL_ANGLE_RADIAN = PLANE_ANGLE * pi / 180;
planeWithAngle = tan(INITIAL_ANGLE_RADIAN) * arrayY;

randomElevation = rand(Y,X);

plane = planeWithAngle + randomElevation;

end % MakeFlatAreas end