% =========================================================================
%> @section INTRO CalcInfinitiveFlow
%>
%> - Tarboton (1997)의 무한 유향 알고리듬을 이용하여 유향과 경사를 구하는 함수
%>
%>  - 주의 : 한 셀씩 연산을 하는 것이 아니라, 격자 단위로 연산을 수행함. 이를
%>    위해 1) 격자의 각 셀을 가리키기 위한 선형 색인(e0LinearIndicies)과
%>    2) e0를 기준으로 이웃 셀(e1, e2)을 가리키기 위한 offset을 생성함. 여기서
%>    e0는 3x3 창의 중앙 셀
%>
%>  - 참고문헌
%>   - Tarboton, "A new method for the determination of flow
%>     directions and upslope areas in grid digital elevation models," Water
%>     Resources Research, vol. 33, no. 2, pages 309-319, February 1997.
%>   - Figure 3. Definition of variables for the calculation of slope 
%>     on a single facet.
%>   - Figure 2. Flow directino defined as steepest downward slope on planar
%>     triangular facets on a block-centered grid.
%> 	 - Table 1. Facet Elevation and Factors for Slope and Angle Calculation, p311
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%>
%> @retval facetFlowDirection       : facet flow 유향 [radian]
%> @retval facetFlowSlope           : facet flow 경사 [radian]
%> @retval e1LinearIndicies         : 다음 셀(e1) 색인
%> @retval e2LinearIndicies         : 다음 셀(e2) 색인
%> @retval outputFluxRatioToE1      : 다음 셀(e1)로의 유입율
%> @retval outputFluxRatioToE2      : 다음 셀(e2)로의 유입율
%>
%> @param mRows                     : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                     : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y                         : 외곽 경계를 제외한 Y축 크기
%> @param X                         : 외곽 경계를 제외한 X축 크기
%> @param Y_INI                     : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                     : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                     : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                     : 모형 영역 X 마지막 좌표값(=X+1) 
%> @param QUARTER_PI                : pi * 0.25
%> @param HALF_PI                   : pi * 0.5
%> @param elev                      : 지표 고도 [m]
%> @param dX                        : 셀 크기 [m]
%> @param sE0LinearIndicies         : 외곽 경계를 제외한 중앙 셀
%> @param s3E1LinearIndicies        : 외곽 경계를 제외한 다음 셀(e1) 색인
%> @param s3E2LinearIndicies        : 외곽 경계를 제외한 다음 셀(e2) 색인
% =========================================================================
function [facetFlowDirection,facetFlowSlope,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1,outputFluxRatioToE2]= CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,QUARTER_PI,HALF_PI,elev,dX,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies)
%
% function CalcInfinitiveFlow
%

% 변수 초기화

% 출력 변수 초기화
facetFlowSlope = nan(mRows,nCols);
facetFlowDirection = nan(mRows,nCols);
e1LinearIndicies = nan(mRows,nCols);
e2LinearIndicies = nan(mRows,nCols);
outputFluxRatioToE1 = nan(mRows,nCols);
outputFluxRatioToE2 = nan(mRows,nCols);

% 연산 변수 초기화
% * 주의 : 연산은 격자 단위로 수행되는데 모델 영역 내부만을 대상으로 하기 때문에
%          경계를 제외한 배열을 생성하고 초기화한다. s는 mRows*nCols보다 작은
%          Y*X 크기를 가지는 행렬을 의미한다.
sFacetFlowSlope = - Inf(Y,X);
% 유향이 없을 경우에는 NaN으로 기록된다.
sFacetFlowDirection = nan(Y,X);
% e1의 선형 색인 초기화
sE1LinearIndicies = nan(Y,X);
% e2의 선형 색인 초기화
sE2LinearIndicies = nan(Y,X);
% e1으로의 전달되는 흐름 비율
sOutputFluxRatioToE1 = nan(Y,X);
% e2으로의 전달되는 흐름 비율
sOutputFluxRatioToE2 = nan(Y,X);

% 개별 셀별로 연산을 수행하여 유향과 경사를 구하는 것이 아니라, 격자(배열)
% 단위로 연산을 수행한다.

% CalcFacetFlow 함수를 이용하여 구한 개별 facet 흐름의 향을 동쪽을 기준으로
% 시계 반대 방향으로 증가하도록 만들어주는 multipliers.
% * 참고 : Tarboton(1997)의 Table 1.
ac = [ 0  1  1  2  2  3  3  4];
af = [ 1 -1  1 -1  1 -1  1 -1];

% sFacetFlowDirection을 이용하여 e1과 e2에 전달되는 흐름의 비율을 구하기 위한
% multipliers * 참고 : Tarboton(1997)의 Figure 2를 구현하기 위함
a1 = [ 1 -1  3 -3  5 -5  7 -7];
b1 = [-1  1 -1  1 -1  1 -1  1];
a2 = [ 0  2 -2  4 -4  6 -6  8];
b2 = [ 1 -1  1 -1  1 -1  1 -1];
            
% e0의 (선형 색인이 가리키는) 고도를 저장한다.
sE0Elevation = elev(sE0LinearIndicies);

% e0를 기준으로 8개 facet 흐름의 향과 경사를 탐색하여, 유향과 경사를 결정한다.
for kthFacet = 1:8

    % k번째 facet의 e1, e2 색인 행렬을 구한다.
    sE1KIndicies = s3E1LinearIndicies(:,:,kthFacet);
    sE2KIndicies = s3E2LinearIndicies(:,:,kthFacet);
    
    % e0의 선형색인과 옵셋을 이용하여 k 번째 facet의 e1, e2의 고도를 구함
    sE1KElevation = elev(sE1KIndicies);
    sE2KElevation = elev(sE2KIndicies);

    % e1과 e2의 고도를 이용하여, k 번째 facet 흐름의 향과 경사를 구함
    [sKFacetFlowDirection,sKFacetFlowSlope] ...
        = CalcFacetFlow(sE0Elevation,sE1KElevation,sE2KElevation,dX);

    % 이전 facet 흐름의 경사보다 크고 경사값이 양에 해당하는 셀들을
    % biggerFacetFlowSloeps으로 표시하고,
    biggerFacetFlowSlope = (sKFacetFlowSlope > sFacetFlowSlope) ...
                         & (sKFacetFlowSlope > 0);
    
    % 이에 해당하는 셀에만 k 번째 facet 흐름의 향을 유향으로 기록한다
    sFacetFlowDirection(biggerFacetFlowSlope) ... % Equation (6)
        = (af(kthFacet) * sKFacetFlowDirection(biggerFacetFlowSlope)) ...
        + (ac(kthFacet) * HALF_PI);  
         
    % 이에 해당하는 셀에 새로 구한 경사값을 입력한다.
    % * 주의 : slope은 유향과 달리 facet 순서와 관련없다. facet 순서와 관련있는
    %          것은 facet flow direction과 flow proportion이다.
    sFacetFlowSlope(biggerFacetFlowSlope) ...
        = sKFacetFlowSlope(biggerFacetFlowSlope);
    
    % 이에 해당하는 셀에 e1과 e2의 선형 색인을 기록한다.
    sE1LinearIndicies(biggerFacetFlowSlope) ...
        = sE1KIndicies(biggerFacetFlowSlope);
    sE2LinearIndicies(biggerFacetFlowSlope) ...
        = sE2KIndicies(biggerFacetFlowSlope);

    % 이에 해당하는 셀에 e1과 e2로의 흐름 비율을 기록한다.
    % Tarboton(1986)의 figure (2)
    sOutputFluxRatioToE1(biggerFacetFlowSlope) ...
        = ( a1(kthFacet) * QUARTER_PI ...
        + b1(kthFacet) * sFacetFlowDirection(biggerFacetFlowSlope) ) ...
        / QUARTER_PI;
    
    sOutputFluxRatioToE2(biggerFacetFlowSlope) ...
        = ( a2(kthFacet) * QUARTER_PI ...
        + b2(kthFacet) * sFacetFlowDirection(biggerFacetFlowSlope) ) ...
        / QUARTER_PI;

end

% 출력 변수(유향,경사,e1 및 e2 선형색인,e1 및 e2로의 흐름비율)의 경계를 설정한다.
% 모델 영역 경계는 NaN으로 기록된다.
facetFlowDirection(Y_INI:Y_MAX,X_INI:X_MAX) = sFacetFlowDirection;
facetFlowSlope(Y_INI:Y_MAX,X_INI:X_MAX) = sFacetFlowSlope;
e1LinearIndicies(Y_INI:Y_MAX,X_INI:X_MAX) = sE1LinearIndicies;
e2LinearIndicies(Y_INI:Y_MAX,X_INI:X_MAX) = sE2LinearIndicies;
outputFluxRatioToE1(Y_INI:Y_MAX,X_INI:X_MAX) = sOutputFluxRatioToE1;
outputFluxRatioToE2(Y_INI:Y_MAX,X_INI:X_MAX) = sOutputFluxRatioToE2;

end % CalcInfinitiveFlow end