% =========================================================================
%> @section INTRO MakeFlatAreas
%>
%> - ������ ��縦 ���� ��ź���� ����� �Լ�
%>  - ���� ��縦 ���� ��ź���̶� �� ������ ���� ��谡 ������ ���¿���
%>    �������� ������ ���� ��簢��ŭ ���� �����ϴ� ��ź��. ���� rand�Լ���
%>    �̿��Ͽ� ��ǥ�� ������ ������ �� �� ����
%>  - ������ �ʱ� ��簢�̶�, DX�� Y�� ũ�⿡ ���� ��ź���� �Ը�� ū ���̸� 
%>     ����
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval plane        : ���� ��縦 ���� ��ź��
%>
%> @param Y             : �ܰ� ��踦 ������ Y�� ũ��
%> @param X             : �ܰ� ��踦 ������ X�� ũ��
%> @param dX            : �� ũ�� [m]
%> @param PLANE_ANGLE   : ���� ���
% =========================================================================
function plane = MakeFlatAreas(Y,X,dX,PLANE_ANGLE)
%
% function MakeFlatAreas
%

distanceY = Y * dX; % Y ���� �� ���� �Ÿ�
distanceX = X * dX;

% * ���� : �Ʒ��� �����ϰ�, ����� ���� �����ϱ� ���� arrayY ����.
[tmp,arrayY] = meshgrid(0.5*dX:dX:distanceX-0.5*dX ...
    ,distanceY-0.5*dX:-dX:0.5*dX);

INITIAL_ANGLE_RADIAN = PLANE_ANGLE * pi / 180;
planeWithAngle = tan(INITIAL_ANGLE_RADIAN) * arrayY;

randomElevation = rand(Y,X);

plane = planeWithAngle + randomElevation;

end % MakeFlatAreas end