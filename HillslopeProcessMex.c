/*
 * HillslopeProcessMex.c
 *
 * 높은 고도 순으로 사면작용에 의한 퇴적물 두께 변화율을 구하는 함수
 * (높은 고도 순으로) 운반능력에 따라 사면물질을 각 이웃 셀에 분배함
 * * 주의: 다음의 이유로 flooded region의 유출구인지를 확인하지 않음 1) 단위
 *   시간이 1년인 경우에 flooded region으로의 유입율이 저장량을 넘는 일이 거의
 *   없음 2) 사면 물질에 의한 이동이므로 flooded region의 유입율이 저장량을
 *   초과하더라도 초과량이 유출구를 통해 이동되지 않는다고 가정함 3) 유출구
 *   여부에 따라 이웃 셀에 분배하는 방식이 달라지지는 않음
 * * 참고: HillslopeProcess 함수(ver 0.7)의 for 반복문만을 MEX 파일로 변경함
 * 
 * [inputFlux ...                   0 상부 유역으로부터의 유입율 [m/dT]
 * ,outputFlux...                   1 이웃 셀로의 총 유출율 [m/dT]
 * ,inputFloodedRegion ...          2 flooded region으로의 유입율 [m/dT]
 * ] = HillslopeProcessMex ...
 * (mRows ...                       0 . 행 개수
 * ,nCols ...                       1 . 열 개수
 * ,consideringCellsNo) ...         2 . 사면작용이 발생하는 셀 수
 *----------------------------- mexGetVariablePtr 함수로 참조하는 변수
 * mexSortedIndicies ...            0 . 고도순으로 정렬된 색인
 * mexSDSNbrIndicies ...            1 . 다음 셀 색인
 * n3IthNbrLinearIndicies ...       2 . 3차원 8방향 이웃 셀 색인
 * flood ...                        3 . flooded region
 * sedimentThick ...                4 . 퇴적물 두께
 * transportCapacityToNbrs ...      5 . 각 이웃 셀로의 사면작용 운반능력
 * sumTransportCapacityToNbrs ...   6 . 총 사면작용 운반능력
 
 *
 */

# include "mex.h"

/* 계산 함수 선언 */
void HillslopeProcessMex(
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mwIndex mRows,
    mwIndex nCols,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * n3IthNbrLinearIndicies,
    double * flood,
    double * sedimentThick,
    double * transportCapacityToNbrs,
    double * sumTransportCapacityToNbrs);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* 입력 변수 선언
     * 주의: mxArray 자료형 변수는 mexGetVariablePtr 함수를 이용하여
     * 호출함수의 작업공간에 있는 변수들의 포인터만 불러옴 */
    /* 호출함수 작업공간의 변수 */
    const mxArray * mxArray0; /* mexSortedIndicies */
    const mxArray * mxArray1; /* mexSDSNbrIndicies*/
    const mxArray * mxArray2; /* n3IthNbrLinearIndicies */
    const mxArray * mxArray3; /* flood */
    const mxArray * mxArray4; /* sedimentThick */
    const mxArray * mxArray5; /* transportCapacityToNbrs */
    const mxArray * mxArray6; /* sumTransportCapacityToNbrs */
    
    /* 입력변수 실제 자료  */
    mwIndex mRows;
    mwIndex nCols;
    mwSize consideringCellsNo;
    double * mexSortedIndicies;
    double * mexSDSNbrIndicies;
    double * n3IthNbrLinearIndicies;
    double * flood;
    double * sedimentThick;
    double * transportCapacityToNbrs;
    double * sumTransportCapacityToNbrs;
    
    /* 출력 변수 선언 */
    double * dSedimentThick;
    double * inputFlux;
    double * outputFlux;
    double * inputFloodedRegion;
    
    /* 입력 변수 초기화 */
    mRows               = (mwIndex) mxGetScalar(prhs[0]);
    nCols               = (mwIndex) mxGetScalar(prhs[1]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[2]);
    
    mxArray0    = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray1    = mexGetVariablePtr("caller","mexSDSNbrIndicies");    
    mxArray2    = mexGetVariablePtr("caller","n3IthNbrLinearIndicies");    
    mxArray3    = mexGetVariablePtr("caller","flood");
    mxArray4    = mexGetVariablePtr("caller","sedimentThick");
    mxArray5    = mexGetVariablePtr("caller","transportCapacityToNbrs");
    mxArray6    = mexGetVariablePtr("caller","sumTransportCapacityToNbrs");
    
    mexSortedIndicies           = mxGetPr(mxArray0);    
    mexSDSNbrIndicies           = mxGetPr(mxArray1);    
    n3IthNbrLinearIndicies      = mxGetPr(mxArray2);    
    flood                       = mxGetPr(mxArray3);    
    sedimentThick               = mxGetPr(mxArray4);    
    transportCapacityToNbrs     = mxGetPr(mxArray5);    
    sumTransportCapacityToNbrs  = mxGetPr(mxArray6);
    
    /* 출력 변수 초기화 */
    plhs[0] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    
    /* 출력 변수 자료에 포인터를 지정 */
    inputFlux           = mxGetPr(plhs[0]);
    outputFlux          = mxGetPr(plhs[1]);
    inputFloodedRegion  = mxGetPr(plhs[2]);
    
    /* 서브 루틴 수행 */
    HillslopeProcessMex(
        inputFlux,
        outputFlux,
        inputFloodedRegion,
        mRows,
        nCols,
        consideringCellsNo,
        mexSortedIndicies,
        mexSDSNbrIndicies,
        n3IthNbrLinearIndicies,
        flood,
        sedimentThick,
        transportCapacityToNbrs,
        sumTransportCapacityToNbrs);
}

void HillslopeProcessMex(
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mwIndex mRows,
    mwIndex nCols,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * n3IthNbrLinearIndicies,
    double * flood,
    double * sedimentThick,
    double * transportCapacityToNbrs,
    double * sumTransportCapacityToNbrs)
{
    /* 임시 변수 선언 */
    const int FLOODED = 2; /* flooded region */
    mwSize ithNbr,ithCell;
    mwIndex ithCellIdx,toIthNbr,ithNbrIdx,outletIdx;
    double scale;    
            
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {
        /* 1. i번째 셀 색인 */
        /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. i번째 셀의 퇴적물 두께를 고려한 이웃 셀로의 실제 이동 비율과 양 */

        /* 1) 실제 이동되는 비율 초기화 */
        /* * 참고: 상부 사면에서의 유입량도 고려하여 실제 이동 비율을 구함.
         *   하지만 일반적으로 확산현상에서는 고도 순서대로 상부로부터의 유입을
         *   고려하여 다음 셀에 전하지 않음 */
        scale = 1;

        /* 2) 사면작용에 의한 총 퇴적물 운반능력이 (상부 사면에서의 유입율을
         *    고려한) 현 퇴적물 두께보다 큰 지를 확인함 */
        if (sumTransportCapacityToNbrs[ithCellIdx]
                > (sedimentThick[ithCellIdx] + inputFlux[ithCellIdx]))
        {
            /* (1) 크다면, 이동 비율을 수정함 */
            scale = (sedimentThick[ithCellIdx] + inputFlux[ithCellIdx])
                / sumTransportCapacityToNbrs[ithCellIdx];
        }
        
        /* 3) 실제 총 운반율 */
        outputFlux[ithCellIdx] = sumTransportCapacityToNbrs[ithCellIdx] * scale;

        /* 3. 각 이웃 셀의 유입율에 유출율을 더함 */
        for (ithNbr=0;ithNbr<8;ithNbr++)
        {
            /* 1) 각 이웃 셀로의 운반능력을 가리키기 위한 색인 */
            /* * 주의: ithCellIdx에서 '-1'을 수행했으므로 또 할 필요가 없음 */
            toIthNbr = ithNbr * (mRows*nCols) + ithCellIdx;
            
            /* 2) i번째 이웃 셀로의 유출량이 있는지를 확인함 */
            if (transportCapacityToNbrs[toIthNbr] > 0)
            {
                /* (1) i번째 이웃 셀로의 유출이 있는 경우 */

                /* A. 3차원 이웃 셀 색인 */
                /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                ithNbrIdx = (mwIndex) n3IthNbrLinearIndicies[toIthNbr] - 1;
                
                /* B. i번째 이웃 셀이 flooded region 인지를 확인함 */
                if (flood[ithNbrIdx] == FLOODED)
                {

                    /* A) flooded region인 경우, inputFloodedRegion의 유입율에
                     *    유출율을 더함 */

                    /* (A) flooded region 유출구 색인 */
                    /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                    outletIdx = (mwIndex) mexSDSNbrIndicies[ithNbrIdx] - 1;
                

                    /* (B) inputFloodedRegion 유입율에 유출율을 더함 */
                    inputFloodedRegion[outletIdx] 
                        = inputFloodedRegion[outletIdx]
                        + scale * transportCapacityToNbrs[toIthNbr];
                }
                else
                {
                    /* B) flooded region이 아닌 경우, i번째 이웃 셀의 유입율에
                     *    유출율을 더함 */
                    inputFlux[ithNbrIdx] = (inputFlux[ithNbrIdx]
                        + scale * transportCapacityToNbrs[toIthNbr]);
                } /* if (flood[ithNbrIdx] == FLOODED) */
            } /* if (transportCapacityToNbrs[toIthNbr] > 0) */
        } /* for (ithNbr=1 */
    } /* for (ithCell=0; */
} /* void HillslopeProcessMex */