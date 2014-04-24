% =========================================================================
%> @section INTRO CalcFacetFlow
%>
%> - 동-북동 facet 흐름의 향과 경사를 구하는 함수
%>  - 참고 : Tarboton(1997)의 figure 3.
%>  - Steven L. Eddins(2007) 이 구현한 것을 수정함.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%>
%> @retval facetFlowDirection       : facet flow 유향 [radian]
%> @retval facetFlowSlope           : facet flow 경사 [radian]
%>
%> @param e0Elev                    : 중앙 셀의 고도 [m]
%> @param e1Elev                    : 다음 셀(e1)의 고도 [m]
%> @param e2Elev                    : 다음 셀(e2)의 고도 [m]
%> @param dX                        : 셀 크기 [m]
% =========================================================================
function [facetFlowDirection,facetFlowSlope] = CalcFacetFlow(e0Elev,e1Elev,e2Elev,dX)
%
% function CalcFacetFlow
%

s1 = (e0Elev - e1Elev) / dX;                % eqn (1)
s2 = (e1Elev - e2Elev) / dX;                % eqn (2)

facetFlowDirection = atan2(s2, s1);                   % eqn (3)
% 주의: atan(s2./s1) 를 사용하지 않음.
% 이는 atan() 결과가 -0.5*pi ~ +0.5*pi 사이로 제한되기 때문임
facetFlowSlope = sqrt(s1.^2 + s2.^2);                 % eqn (3)

% facet 흐름의 향은 내부 또는 최소한 경계에 위치한다.
% 남쪽 경계를 넘을 때
tooFarSouth = facetFlowDirection < 0;                 % eqn (4)

facetFlowDirection(tooFarSouth) = 0;                  % eqn (4)

facetFlowSlope(tooFarSouth) = s1(tooFarSouth);        % eqn (4)

diagonalAngle = atan2(dX, dX);

% 북쪽 경계를 넘을 때
diagonalDistance = sqrt(dX^2 + dX^2);                 % eqn (5)

tooFarNorth = facetFlowDirection > diagonalAngle;     % eqn (5)

facetFlowDirection(tooFarNorth) = diagonalAngle;      % eqn (5)

facetFlowSlope(tooFarNorth) ...
= (e0Elev(tooFarNorth) - e2Elev(tooFarNorth)) / diagonalDistance; % eqn (5)

end % CalcFacetFlow end