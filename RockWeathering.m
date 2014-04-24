% =========================================================================
%> @section INTRO RockWeathering
%>
%> - 단위시간 당 풍화율을 추정하는 함수.
%>  - 전제 : 하도에서는 풍화가 발생하지 않으며, 풍화로 인한 부피 변화는 없음
%>  - Anderson(2002)의 수식을 근거로 함
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval weatheringProductPerDT   : 단위시간 당 풍화율 [m/dT]
%>
%> @param kwa                       : 선형 풍화 함수의 증가율
%> @param kw0                       : 선형 풍화 함수에서 연장되는 노출 기반암의 풍화율 [m/yr]
%> @param kw1                       : 지수 감소 풍화 함수에서 연장되는 노출 기반암의 풍화율 [m/yr]
%> @param kwm                       : 풍화층 두께 축적 [m]
%> @param sedThickOutsideChannel    : 하도 부피를 고려한 하안 퇴적층 두께 [m]
%> @param bankfullWidth             : 만수유량시 하폭 [m]
%> @param dX                        : 셀 크기 [m]
%> @param dT                        : 만수유량 재현기간
% =========================================================================
function weatheringProductPerDT = RockWeathering(kwa,kw0,kw1,kwm,sedThickOutsideChannel,bankfullWidth,dX,dT)
%
% 단위시간 당 풍화율을 추정하는 함수.
%

% 단위시간 당 풍화율 [m/dT]
weatheringProductPerDT ...
    = min( kwa * sedThickOutsideChannel + kw0  ...
    , kw1 .* exp(- sedThickOutsideChannel ./ kwm) ) ...
    .* (dX - bankfullWidth) ./ dX ...                      % 하도를 제외함
    .* dT;                                                 % 단위변환 [m/dT]

end % RockWeathering end