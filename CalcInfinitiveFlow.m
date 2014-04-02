% =========================================================================
%> @section INTRO CalcInfinitiveFlow
%>
%> - Tarboton (1997)�� ���� ���� �˰����� �̿��Ͽ� ����� ��縦 ���ϴ� �Լ�
%>
%>  - ���� : �� ���� ������ �ϴ� ���� �ƴ϶�, ���� ������ ������ ������. �̸�
%>    ���� 1) ������ �� ���� ����Ű�� ���� ���� ����(e0LinearIndicies)��
%>    2) e0�� �������� �̿� ��(e1, e2)�� ����Ű�� ���� offset�� ������. ���⼭
%>    e0�� 3x3 â�� �߾� ��
%>
%>  - ������
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
%> @retval facetFlowDirection       : facet flow ���� [radian]
%> @retval facetFlowSlope           : facet flow ��� [radian]
%> @retval e1LinearIndicies         : ���� ��(e1) ����
%> @retval e2LinearIndicies         : ���� ��(e2) ����
%> @retval outputFluxRatioToE1      : ���� ��(e1)���� ������
%> @retval outputFluxRatioToE2      : ���� ��(e2)���� ������
%>
%> @param mRows                     : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                     : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y                         : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                         : �ܰ� ��踦 ������ X�� ũ��
%> @param Y_INI                     : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                     : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                     : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                     : ���� ���� X ������ ��ǥ��(=X+1) 
%> @param QUARTER_PI                : pi * 0.25
%> @param HALF_PI                   : pi * 0.5
%> @param elev                      : ��ǥ �� [m]
%> @param dX                        : �� ũ�� [m]
%> @param sE0LinearIndicies         : �ܰ� ��踦 ������ �߾� ��
%> @param s3E1LinearIndicies        : �ܰ� ��踦 ������ ���� ��(e1) ����
%> @param s3E2LinearIndicies        : �ܰ� ��踦 ������ ���� ��(e2) ����
% =========================================================================
function [facetFlowDirection,facetFlowSlope,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1,outputFluxRatioToE2]= CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,QUARTER_PI,HALF_PI,elev,dX,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies)
%
% function CalcInfinitiveFlow
%

% ���� �ʱ�ȭ

% ��� ���� �ʱ�ȭ
facetFlowSlope = nan(mRows,nCols);
facetFlowDirection = nan(mRows,nCols);
e1LinearIndicies = nan(mRows,nCols);
e2LinearIndicies = nan(mRows,nCols);
outputFluxRatioToE1 = nan(mRows,nCols);
outputFluxRatioToE2 = nan(mRows,nCols);

% ���� ���� �ʱ�ȭ
% * ���� : ������ ���� ������ ����Ǵµ� �� ���� ���θ��� ������� �ϱ� ������
%          ��踦 ������ �迭�� �����ϰ� �ʱ�ȭ�Ѵ�. s�� mRows*nCols���� ����
%          Y*X ũ�⸦ ������ ����� �ǹ��Ѵ�.
sFacetFlowSlope = - Inf(Y,X);
% ������ ���� ��쿡�� NaN���� ��ϵȴ�.
sFacetFlowDirection = nan(Y,X);
% e1�� ���� ���� �ʱ�ȭ
sE1LinearIndicies = nan(Y,X);
% e2�� ���� ���� �ʱ�ȭ
sE2LinearIndicies = nan(Y,X);
% e1������ ���޵Ǵ� �帧 ����
sOutputFluxRatioToE1 = nan(Y,X);
% e2������ ���޵Ǵ� �帧 ����
sOutputFluxRatioToE2 = nan(Y,X);

% ���� ������ ������ �����Ͽ� ����� ��縦 ���ϴ� ���� �ƴ϶�, ����(�迭)
% ������ ������ �����Ѵ�.

% CalcFacetFlow �Լ��� �̿��Ͽ� ���� ���� facet �帧�� ���� ������ ��������
% �ð� �ݴ� �������� �����ϵ��� ������ִ� multipliers.
% * ���� : Tarboton(1997)�� Table 1.
ac = [ 0  1  1  2  2  3  3  4];
af = [ 1 -1  1 -1  1 -1  1 -1];

% sFacetFlowDirection�� �̿��Ͽ� e1�� e2�� ���޵Ǵ� �帧�� ������ ���ϱ� ����
% multipliers * ���� : Tarboton(1997)�� Figure 2�� �����ϱ� ����
a1 = [ 1 -1  3 -3  5 -5  7 -7];
b1 = [-1  1 -1  1 -1  1 -1  1];
a2 = [ 0  2 -2  4 -4  6 -6  8];
b2 = [ 1 -1  1 -1  1 -1  1 -1];
            
% e0�� (���� ������ ����Ű��) ���� �����Ѵ�.
sE0Elevation = elev(sE0LinearIndicies);

% e0�� �������� 8�� facet �帧�� ��� ��縦 Ž���Ͽ�, ����� ��縦 �����Ѵ�.
for kthFacet = 1:8

    % k��° facet�� e1, e2 ���� ����� ���Ѵ�.
    sE1KIndicies = s3E1LinearIndicies(:,:,kthFacet);
    sE2KIndicies = s3E2LinearIndicies(:,:,kthFacet);
    
    % e0�� �������ΰ� �ɼ��� �̿��Ͽ� k ��° facet�� e1, e2�� ���� ����
    sE1KElevation = elev(sE1KIndicies);
    sE2KElevation = elev(sE2KIndicies);

    % e1�� e2�� ���� �̿��Ͽ�, k ��° facet �帧�� ��� ��縦 ����
    [sKFacetFlowDirection,sKFacetFlowSlope] ...
        = CalcFacetFlow(sE0Elevation,sE1KElevation,sE2KElevation,dX);

    % ���� facet �帧�� ��纸�� ũ�� ��簪�� �翡 �ش��ϴ� ������
    % biggerFacetFlowSloeps���� ǥ���ϰ�,
    biggerFacetFlowSlope = (sKFacetFlowSlope > sFacetFlowSlope) ...
                         & (sKFacetFlowSlope > 0);
    
    % �̿� �ش��ϴ� ������ k ��° facet �帧�� ���� �������� ����Ѵ�
    sFacetFlowDirection(biggerFacetFlowSlope) ... % Equation (6)
        = (af(kthFacet) * sKFacetFlowDirection(biggerFacetFlowSlope)) ...
        + (ac(kthFacet) * HALF_PI);  
         
    % �̿� �ش��ϴ� ���� ���� ���� ��簪�� �Է��Ѵ�.
    % * ���� : slope�� ����� �޸� facet ������ ���þ���. facet ������ �����ִ�
    %          ���� facet flow direction�� flow proportion�̴�.
    sFacetFlowSlope(biggerFacetFlowSlope) ...
        = sKFacetFlowSlope(biggerFacetFlowSlope);
    
    % �̿� �ش��ϴ� ���� e1�� e2�� ���� ������ ����Ѵ�.
    sE1LinearIndicies(biggerFacetFlowSlope) ...
        = sE1KIndicies(biggerFacetFlowSlope);
    sE2LinearIndicies(biggerFacetFlowSlope) ...
        = sE2KIndicies(biggerFacetFlowSlope);

    % �̿� �ش��ϴ� ���� e1�� e2���� �帧 ������ ����Ѵ�.
    % Tarboton(1986)�� figure (2)
    sOutputFluxRatioToE1(biggerFacetFlowSlope) ...
        = ( a1(kthFacet) * QUARTER_PI ...
        + b1(kthFacet) * sFacetFlowDirection(biggerFacetFlowSlope) ) ...
        / QUARTER_PI;
    
    sOutputFluxRatioToE2(biggerFacetFlowSlope) ...
        = ( a2(kthFacet) * QUARTER_PI ...
        + b2(kthFacet) * sFacetFlowDirection(biggerFacetFlowSlope) ) ...
        / QUARTER_PI;

end

% ��� ����(����,���,e1 �� e2 ��������,e1 �� e2���� �帧����)�� ��踦 �����Ѵ�.
% �� ���� ���� NaN���� ��ϵȴ�.
facetFlowDirection(Y_INI:Y_MAX,X_INI:X_MAX) = sFacetFlowDirection;
facetFlowSlope(Y_INI:Y_MAX,X_INI:X_MAX) = sFacetFlowSlope;
e1LinearIndicies(Y_INI:Y_MAX,X_INI:X_MAX) = sE1LinearIndicies;
e2LinearIndicies(Y_INI:Y_MAX,X_INI:X_MAX) = sE2LinearIndicies;
outputFluxRatioToE1(Y_INI:Y_MAX,X_INI:X_MAX) = sOutputFluxRatioToE1;
outputFluxRatioToE2(Y_INI:Y_MAX,X_INI:X_MAX) = sOutputFluxRatioToE2;

end % CalcInfinitiveFlow end