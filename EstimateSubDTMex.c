/*
 * EstimateSubDTMex.c
 *
 *  (높은 고도의 셀부터) 하류방향 셀과의 경사가 0이 되는 시간을 추정하는 함수
 *  EstimateSubDT 함수(ver 0.8)의 for 반복문만을 mex 파일로 변경함
 % 
 * takenTime ...                0 하류방향 셀과의 경사가 0이 되는 시간 [s]
 * = EstimateSubDTMex ...
 * (mRows ...                   0 . 행 개수
 * ,nCols ...                   1 . 열 개수
 * ,consideringCellsNo)         2 . 하천작용이 발생하는 셀 수
 *----------------------------- mexGetVariablePtr 함수로 참조하는 변수
 * mexSortedIndicies ...        3 . 고도순으로 정렬된 색인
 * e1LinearIndicies ...         4 . 다음 셀 색인
 * e2LinearIndicies ...         5 . 다음 셀 색인
 * outputFluxRatioToE1 ...      6 . 다음 셀로의 유출 비율
 * outputFluxRatioToE2 ...      7 . 다음 셀로의 유출 비율
 * mexSDSNbrIndicies ...        8 . 다음 셀 색인
 * floodedRegionCellsNo ...     9 . flooded region 구성 셀 수
 * dElev ...                    10 . 고도 변화율 [m/trialTime]
 * elev ...                     11 . 고도 [m]
 *----------------------------- mexGetVariable 함수로 복사해오는 변수
 * takenTime ...                0 . inf로 초기화된 출력 변수
 *
 */

# include "mex.h"
# include "matrix.h"

/* computational routine */
void EstimateSubDTMex(
    double * takenTime,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * floodedRegionCellsNo,
    double * dElev,
    double * elev);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* check for proper number of arguments */
    /* validate the input values */
    
    /* variable declaration */
    /* input variable declaration */
    mwSize mRows;
    mwSize nCols;
    mwSize consideringCellsNo;
    /* 주의: mxArray 자료형 변수는 mexGetVariablePtr 함수를 이용하여
     * 호출함수의 작업공간에 있는 변수들의 포인터만 불러옴 */
    const mxArray * mxArray3;
    const mxArray * mxArray4;
    const mxArray * mxArray5;
    const mxArray * mxArray6;
    const mxArray * mxArray7;
    const mxArray * mxArray8;
    const mxArray * mxArray9;
    const mxArray * mxArray10;
    const mxArray * mxArray11;
    double * mexSortedIndicies;
    double * e1LinearIndicies;
    double * e2LinearIndicies;
    double * outputFluxRatioToE1;
    double * outputFluxRatioToE2;
    double * mexSDSNbrIndicies;
    double * floodedRegionCellsNo;
    double * dElev;
    double * elev;
    
    /* output variable declaration */
    double * takenTime;
            
    /* create a pointer to the real data in the input matrix */
    mRows               = (mwSize) mxGetScalar(prhs[0]);
    nCols               = (mwSize) mxGetScalar(prhs[1]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[2]);
    
    mxArray3  = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray4  = mexGetVariablePtr("caller","e1LinearIndicies");    
    mxArray5  = mexGetVariablePtr("caller","e2LinearIndicies");    
    mxArray6  = mexGetVariablePtr("caller","outputFluxRatioToE1");
    mxArray7  = mexGetVariablePtr("caller","outputFluxRatioToE2");
    mxArray8  = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray9  = mexGetVariablePtr("caller","floodedRegionCellsNo");
    mxArray10 = mexGetVariablePtr("caller","dElev");
    mxArray11 = mexGetVariablePtr("caller","elev");
    
    mexSortedIndicies      = mxGetPr(mxArray3);    
    e1LinearIndicies       = mxGetPr(mxArray4);    
    e2LinearIndicies       = mxGetPr(mxArray5);    
    outputFluxRatioToE1    = mxGetPr(mxArray6);    
    outputFluxRatioToE2    = mxGetPr(mxArray7);    
    mexSDSNbrIndicies      = mxGetPr(mxArray8);    
    floodedRegionCellsNo   = mxGetPr(mxArray9);    
    dElev                  = mxGetPr(mxArray10);
    elev                   = mxGetPr(mxArray11);
    
    /* prepare output data */
    /* create the output matrix */
    plhs[0] = mexGetVariable("caller","takenTime");
    
    /* get a pointer to the real data in the output matrix */
    takenTime = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    EstimateSubDTMex(
        takenTime,
        consideringCellsNo,
        mexSortedIndicies,
        e1LinearIndicies,
        e2LinearIndicies,
        outputFluxRatioToE1,
        outputFluxRatioToE2,
        mexSDSNbrIndicies,
        floodedRegionCellsNo,
        dElev,
        elev);

}

void EstimateSubDTMex(
    double * takenTime,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * floodedRegionCellsNo,
    double * dElev,
    double * elev)
{
    /* 임시 변수 선언 */
    mwIndex ithCell,ithCellIdx,e1,e2,next;
    
    double inf;
    double takenTimeForE1,takenTimeForE2;
    
    /* takenTimeForE1, takenTimeForE2 변수 초기화 */
    inf = mxGetInf();
    takenTimeForE1 = inf;
    takenTimeForE2 = inf;
    
    /* (높은 고도의 셀부터) 다음 셀과의 경사가 0이 되는 시간을 추정함 */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {
        /* 1. i번째 셀 색인
         * * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. i번째 셀이 유출구인지 확인함 */
        if ((int) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* 1) 유출구가 아니라면, i번째 셀의 고도 변화율을 무한 유향을 따라
             *    다음 셀들의 고도 변화율과 비교함
             * * 원리: 다음 셀들(e1,e2)의 침식율이 더 작은 경우, trialTime내에
             *   상류와 하류의 기복이 역전됨. 따라서 기복 역전이 발생하기
             *   직전까지의 시간, 즉 다음 셀들(e1,e2)과의 경사가 0이 되는데
             *   걸리는 시간[trialTime]을 구하고 이를 나중에 세부 단위시간으로
             *   설정함.
             * * 주의: 다음 셀로의 흐름 비율이 적어도 0.0000001 보다는 큰
             *   경우에만 시간을 구함. e1 또는 e2 중 한 셀로만 흐름이
             *   전달되더라도 유효숫자 한계로 인해 흐름 비율이 정확하게 1 또는
             *   0이 되지 않기 때문임. 즉 적어도 0.0000001 보다 클 경우에만
             *   경우에만 흐름이 전달된다고 가정함. 따라서 이보다 작은 경우에는
             *   연산이 불필요함 */
            
            /* (1) 다음 셀 색인 */
            /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
            e1 = (mwIndex) e1LinearIndicies[ithCellIdx] - 1;
            e2 = (mwIndex) e2LinearIndicies[ithCellIdx] - 1;

            /* (2) i번째 셀의 고도 변화율이 e1의 고도 변화율보다 적다면, 다음
             *     다음 셀과의 경사가 0이 되는데 걸리는 시간을 구함
             * * 주의: takenTimeForX의 분자는 항상 음의 값을 가짐 따라서 if
             *   조건문이 참인 경우 분모 또한 음의 값을 가지므로 전체는 항상
             *   양의 값을 가짐 */            
            if ((dElev[ithCellIdx] < dElev[e1])
                && (outputFluxRatioToE1[ithCellIdx] > 0.0000001))
            {
                takenTimeForE1 = (elev[e1] - elev[ithCellIdx])
                    / (dElev[ithCellIdx] - dElev[e1]);
            }            

            /* (3) i번째 셀의 고도 변화율이 e2의 고도 변화율보다 적다면, 다음
             *     셀과의 경사가 0이 되는데 걸리는 시간을 구함 */
            if ((dElev[ithCellIdx] < dElev[e2])
                && (outputFluxRatioToE2[ithCellIdx] > 0.0000001))
            {
                takenTimeForE2 = (elev[e2] - elev[ithCellIdx])
                    / (dElev[ithCellIdx] - dElev[e2]);
            }

            /* (4) e1과 e2중 소요 시간이 적은 것을 최종 소요 시간으로 기록함 */
            if (takenTimeForE1 <= takenTimeForE2)
            {
                    takenTime[ithCellIdx] = takenTimeForE1;
            }
            else
            {                    
                    takenTime[ithCellIdx] = takenTimeForE2;
            }
            
            /* (5) takenTimeForE1, takenTimeForE2 변수 초기화 */
            takenTimeForE1 = inf;
            takenTimeForE2 = inf;
        }
        else /* (int) floodedRegionCellsNo[ithCellIdx] != 0 */
        {
            /* 2) 유출구인 경우에는 i번째 셀의 고도 변화율을 최대하부경사
             *    유향을 따라 다음 셀의 고도 변화율과 비교함 */
            
            /* (1) 다음 셀 색인
             * * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;
    
            /* (2) i번째 셀의 고도 변화율이 다음 셀의 고도 변화율보다 작다면
             *     작다면 다음 셀과의 경사가 0이 되는데 걸리는 시간을 구함 */
            if (dElev[ithCellIdx] < dElev[next])
            {
                takenTime[ithCellIdx] = (elev[next] - elev[ithCellIdx])
                    / (dElev[ithCellIdx] - dElev[next]);
            }

        } /* (int) floodedRegionCellsNo[ithCellIdx] == 0 */
    } /* for (ithCell=0 */
} /* void EstimateDElevByFluvialProcess( */