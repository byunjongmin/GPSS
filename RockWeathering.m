% =========================================================================
%> @section INTRO RockWeathering
%>
%> - �����ð� �� ǳȭ���� �����ϴ� �Լ�.
%>  - ���� : �ϵ������� ǳȭ�� �߻����� ������, ǳȭ�� ���� ���� ��ȭ�� ����
%>  - Anderson(2002)�� ������ �ٰŷ� ��
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval weatheringProductPerDT   : �����ð� �� ǳȭ�� [m/dT]
%>
%> @param kwa                       : ���� ǳȭ �Լ��� ������
%> @param kw0                       : ���� ǳȭ �Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/yr]
%> @param kw1                       : ���� ���� ǳȭ �Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/yr]
%> @param kwm                       : ǳȭ�� �β� ���� [m]
%> @param sedThickOutsideChannel    : �ϵ� ���Ǹ� ����� �Ͼ� ������ �β� [m]
%> @param bankfullWidth             : ���������� ���� [m]
%> @param dX                        : �� ũ�� [m]
%> @param dT                        : �������� �����Ⱓ
% =========================================================================
function weatheringProductPerDT = RockWeathering(kwa,kw0,kw1,kwm,sedThickOutsideChannel,bankfullWidth,dX,dT)
%
% �����ð� �� ǳȭ���� �����ϴ� �Լ�.
%

% �����ð� �� ǳȭ�� [m/dT]
weatheringProductPerDT ...
    = min( kwa * sedThickOutsideChannel + kw0  ...
    , kw1 .* exp(- sedThickOutsideChannel ./ kwm) ) ...
    .* (dX - bankfullWidth) ./ dX ...                      % �ϵ��� ������
    .* dT;                                                 % ������ȯ [m/dT]

end % RockWeathering end