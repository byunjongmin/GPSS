% =========================================================================
%> @section INTRO CalcFacetFlow
%>
%> - ��-�ϵ� facet �帧�� ��� ��縦 ���ϴ� �Լ�
%>  - ���� : Tarboton(1997)�� figure 3.
%>  - Steven L. Eddins(2007) �� ������ ���� ������.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%>
%> @retval facetFlowDirection       : facet flow ���� [radian]
%> @retval facetFlowSlope           : facet flow ��� [radian]
%>
%> @param e0Elev                    : �߾� ���� �� [m]
%> @param e1Elev                    : ���� ��(e1)�� �� [m]
%> @param e2Elev                    : ���� ��(e2)�� �� [m]
%> @param dX                        : �� ũ�� [m]
% =========================================================================
function [facetFlowDirection,facetFlowSlope] = CalcFacetFlow(e0Elev,e1Elev,e2Elev,dX)
%
% function CalcFacetFlow
%

s1 = (e0Elev - e1Elev) / dX;                % eqn (1)
s2 = (e1Elev - e2Elev) / dX;                % eqn (2)

facetFlowDirection = atan2(s2, s1);                   % eqn (3)
% ����: atan(s2./s1) �� ������� ����.
% �̴� atan() ����� -0.5*pi ~ +0.5*pi ���̷� ���ѵǱ� ������
facetFlowSlope = sqrt(s1.^2 + s2.^2);                 % eqn (3)

% facet �帧�� ���� ���� �Ǵ� �ּ��� ��迡 ��ġ�Ѵ�.
% ���� ��踦 ���� ��
tooFarSouth = facetFlowDirection < 0;                 % eqn (4)

facetFlowDirection(tooFarSouth) = 0;                  % eqn (4)

facetFlowSlope(tooFarSouth) = s1(tooFarSouth);        % eqn (4)

diagonalAngle = atan2(dX, dX);

% ���� ��踦 ���� ��
diagonalDistance = sqrt(dX^2 + dX^2);                 % eqn (5)

tooFarNorth = facetFlowDirection > diagonalAngle;     % eqn (5)

facetFlowDirection(tooFarNorth) = diagonalAngle;      % eqn (5)

facetFlowSlope(tooFarNorth) ...
= (e0Elev(tooFarNorth) - e2Elev(tooFarNorth)) / diagonalDistance; % eqn (5)

end % CalcFacetFlow end