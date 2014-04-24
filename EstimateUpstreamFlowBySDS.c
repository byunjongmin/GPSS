/* 
 * EstimateUpstreamFlowBySDS.c
 *
 * flooded region을 제외한 셀들을 대상으로 상부 유역으로부터의 유량과 누적 셀
 * 개수를 구하는 함수. AccumulateUpstreamFlow 함수의 for 반복문만을 C로 변경함
 * * 주의: 현재 상부 유역 누적 셀 개수는 필요하지 않으므로 주석 처리함
 *
 * [upstreamDischarge1 ...              0 상부 유역으로부터의 유량 [m^3]
 * ,inputDischarge ...                  1 상부 유역으로부터의 유량 [m^3]
 * ,dischargeInputInFloodedRegion ...   2 flooded region으로의 유량
 * ,isOverflowing ...                   3 flooded region 저장량 초과 태그
 * ,upstreamCellsNo ...                 4 상부 유역의 누적 셀 개수
 * ,inputCellsNo ...                    5 상부 유역의 누적 셀 개수 
 * ] = EstimateUpstreamFlow ...
 * (CELL_AREA, ...                      0 셀 면적
 * ,consideringCellsNo ...              1 상부 유역 유량과 셀 개수를 구하는 셀 수
 * ,annualRunoff)                       2 연간 유출량
 * -------------------------------- mexGetVariabelPtr 함수로 참조하는 변수들
 * upstreamDischarge1 ...               3 상부 유역으로부터의 유출량 초기값
 * mexSortedIndicies ...                4 고도순으로 정렬된 색인
 * mexSDSNbrLinearIndicies ...          9 다음 셀 색인
 * flood ...                            10 flooded region
 * floodedRegionStorageVolume ...       11 flooded region 저장량 [m^3]
 * floodedRegionCellsNo ...             12 flooded region 구성 셀 개수
 * upstreamCellsNo ...                  13 상부 유역의 누적 셀 개수 초기값
 *
 */

# include "mex.h"

/* 계산 함수 선언 */
void EstimateUpstreamFlow(
    double * upstreamDischarge1,
    double * inputDischarge,
    double * dischargeInputInFloodedRegion,
    mxLogical * isOverflowing,
    /* double * upstreamCellsNo, */
    /* double * inputCellsNo, */
    int CELL_AREA,
    mwSize consideringCellsNo,
    double annualRunoff,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* 입력 변수 선언
     * 주의: mxArray 자료형 변수는 mexGetVariablePtr 함수를 이용하여
     * 호출함수의 작업공간에 있는 변수들의 포인터만 불러옴 */
    /* 호출함수 작업공간의 변수 */
    mxArray         * mxArray3; /* upstreamDischarge1 */
    const mxArray   * mxArray4; /* mexSortedIndicies */
    const mxArray   * mxArray9; /* mexSDSNbrIndicies */
    const mxArray   * mxArray10; /* flood */
    const mxArray   * mxArray11; /* floodedRegionStorageVolume */
    const mxArray   * mxArray12; /* floodedRegionCellsNo */
    /* mxArray         * mxArray13; /* upstreamCellsNo */
    
    /* 입력변수 실제 자료 */
    int CELL_AREA;
    mwSize consideringCellsNo;
    double annualRunoff;
    
    double * mexSortedIndicies;
    double * mexSDSNbrIndicies;
    double * flood;
    double * floodedRegionCellsNo;
    double * floodedRegionStorageVolume;
    
    /* 출력 변수 선언 */
    double * upstreamDischarge1;
    double * inputDischarge;
    double * dischargeInputInFloodedRegion;
    mxLogical * isOverflowing;
    /*double * upstreamCellsNo; */
    /*double * inputCellsNo; */
    
    /* 임시 변수 선언 */
    mwSize mRows,nCols;
    
    /* 입력 변수 초기화 */      
    CELL_AREA           = (int) mxGetScalar(prhs[0]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[1]);
    annualRunoff        = mxGetScalar(prhs[2]);
    
	mxArray3    = mexGetVariable("caller","upstreamDischarge1");    
    mxArray4    = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray9    = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray10   = mexGetVariablePtr("caller","flood");
    mxArray11   = mexGetVariablePtr("caller","floodedRegionStorageVolume");
    mxArray12   = mexGetVariablePtr("caller","floodedRegionCellsNo");    
    /* mxArray13   = mexGetVariable("caller","upstreamCellsNo"); */
        
    /* upstreamDischarge1 */
    mexSortedIndicies           = mxGetPr(mxArray4);    
    mexSDSNbrIndicies           = mxGetPr(mxArray9);    
    flood                       = mxGetPr(mxArray10);    
    floodedRegionStorageVolume  = mxGetPr(mxArray11);
    floodedRegionCellsNo        = mxGetPr(mxArray12);    
    
    /* 출력 변수 초기화 */
	plhs[0] = mxArray3;
	    
    mRows = (mwSize) mxGetM(plhs[0]);
    nCols = (mwSize) mxGetN(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[3] = mxCreateLogicalMatrix(mRows,nCols);
    /* plhs[4] = mxArray13; */
    /* plhs[5] = mxCreateDoubleMatrix(mRows,nCols,mxREAL); */
    
    /* 출력 변수 자료에 포인터를 지정 */
    upstreamDischarge1              = mxGetPr(plhs[0]);
    inputDischarge                  = mxGetPr(plhs[1]);
    dischargeInputInFloodedRegion   = mxGetPr(plhs[2]);
    isOverflowing                   = mxGetLogicals(plhs[3]);    
    /* upstreamCellsNo                 = mxGetPr(plhs[4]); */
    /* inputCellsNo                    = mxGetPr(plhs[5]); */
    
    /* 서브 루틴 수행 */
    EstimateUpstreamFlow(
        upstreamDischarge1,
        inputDischarge,
        dischargeInputInFloodedRegion,
        isOverflowing,
        /* upstreamCellsNo, */
        /* inputCellsNo, */
        CELL_AREA,
        consideringCellsNo,
        annualRunoff,
        mexSortedIndicies,
        mexSDSNbrIndicies,
        flood,
        floodedRegionCellsNo,
        floodedRegionStorageVolume);
}

void EstimateUpstreamFlow(
    double * upstreamDischarge1,
    double * inputDischarge,
    double * dischargeInputInFloodedRegion,
    mxLogical * isOverflowing,
    /* double * upstreamCellsNo, */
    /* double * inputCellsNo, */
    int CELL_AREA,
    mwSize consideringCellsNo,
    double annualRunoff,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume)
{    
    /* 임시 변수 선언 */
    mwIndex ithCell,ithCellIdx,outlet,next;
    double outputDischargeToNext;
    /* double outputCellsNoToE1,outputCellsNoToE2; */

    const int FLOODED = 2; /* flooded region */
    const int TRUE = 1;

    /* (높은 고도 순으로) 상부 유역으로부터의 유량과 누적 셀 개수를 구함 */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {
        /* 1. i번째 셀 색인 */
        /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. 상부 유역으로부터의 유량과 누적 셀 개수를 유향을 따라 다음 셀에 분배함 */
        /* 1) i번째 셀이 flooded region 유출구가 아니라면, SDS 유향을 따라 다음
         *    셀에 분배함
         * 2) i번째 셀이 flooded region 유출구라면, mexSDSNbrIndicies를 따라 다음
         *    셀에 분배함 */

        /* 1) i번째 셀이 flooded region 유출구가 아니라면(일반적인 경우) 현재 셀의
         *    지표 유출량과 셀 개수 1을 상부 유역으로부터의 유량과 누적 셀 개수에
         *    각각 더하여 SDS 유향을 따라 다음 셀에 분배함 */
        if ((int) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* (1) 상부 유역으로부터 유입되는 유량과 누적 셀 개수에 현재 셀의 지표
             *     유출량과 셀 개수 1을 더함 */
            upstreamDischarge1[ithCellIdx]
                = upstreamDischarge1[ithCellIdx] + inputDischarge[ithCellIdx];
            
	        /*upstreamCellsNo[ithCellIdx]
            /*    = upstreamCellsNo[ithCellIdx] + inputCellsNo[ithCellIdx];

            /* (2) 유량과 누적 셀 개수를 유향을 따라 다음 셀에 분배함 */

            /* A. next의 유입량에 각각 전해질 유량과 누적 셀 개수를 구함 */
            outputDischargeToNext = upstreamDischarge1[ithCellIdx];
            
            /*outputCellsNoToNext = upstreamCellsNo[ithCellIdx];
             
            /* B. 다음 셀이 flooded region에 해당하는지 확인해보고,
             *    flooded region에 해당한다면 상부 유역으로부터의 유량과
             *    누적 셀 개수를 flooded region의 유입량에 반영하고,
             *    아니라면 다음 셀의 유입량에 반영함 */

            /* 다음 셀 색인
             * * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;
            
            /* A) next가 flooded region에 해당하는지 확인함 */
            if ( (int) flood[next] == FLOODED )
            {

                /* (A) next가 flooded region에 해당한다면 유량과 누적 셀 개수를
                 *     flooded region의 유입량으로 반영함
                 * * 주의: 유량과 셀 개수의 처리 방식이 서로 다름
                 *   유량의 경우 flooded region의 저수량 초과분이 유출구에
                 *   전해지기 때문에 유출구의 유입량에 바로 더하지 않음 */

                /* a. flooded region의 유출구 색인 */
                /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                outlet = (mwIndex) mexSDSNbrIndicies[next] - 1;

                /* b. 유량을 더할 때는 flooded region의 유입량에 기록함 */
                dischargeInputInFloodedRegion[outlet]
                  = dischargeInputInFloodedRegion[outlet] + outputDischargeToNext;

                /* c. 누적 셀 개수를 더할 때는 유출구의 유입량에 기록함 */
                /* inputCellsNo[outlet] = inputCellsNo[outlet] + outputCellsNoToNext; */
            }
            else
            {
                /* (B) next가 flooded region이 아니라면, next의 유입량에 상부 
                 *     유역으로부터의 유량과 누적 셀 개수를 더함 */
                inputDischarge[next] = inputDischarge[next] + outputDischargeToNext;

                /* inputCellsNo[next] = inputCellsNo[next] + outputCellsNoToNext; */
            }
        }
        /* (2) i번째 셀이 flooded region의 유출구라면 SDSNbrIndicies가 
         *     가리키는 다음 셀로 상부 유역의 유량과 셀의 갯수를 전달함
         *     참고: ProcessSink 함수에서 유출구의 유향이 flooded region을 다시
         *     향하지 않도록 SDSNbrY,SDSNbrX에 수정을 가했음 */
        else
        {
            /* A. 상부 유역으로부터의 유입량에 flooded region의 저수량을 초과하는
             *    양을 더함 */

            /* A) flooded region으로의 유입량이 저수량을 초과하는지 확인하고
             *    초과할 경우 초과량을 상부 유역으로부터의 유입량으로 인정함
             * * 주의: 실제 지배유량은 빈도가 1년 내에도 여러 번 발생할 확률이 있음
             *   하지만 여기서는 지배유량이 1년에 한 차례있는 것으로 가정함 */

            /* (A) flooded region의 유입량에 지표유출량 합계를 더함 */
            dischargeInputInFloodedRegion[ithCellIdx]
                = dischargeInputInFloodedRegion[ithCellIdx]
                + floodedRegionCellsNo[ithCellIdx] * annualRunoff * CELL_AREA;

            /* (B) flooded region의 저수량과 유입량을 비교함 */
            if (dischargeInputInFloodedRegion[ithCellIdx]
                > floodedRegionStorageVolume[ithCellIdx])
            {
                /* a. flooded region의 초과 유입량을 i번째 셀의 유입량에 더함 */
                inputDischarge[ithCellIdx] = inputDischarge[ithCellIdx]
                    + ( dischargeInputInFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx] );

                /* b. flooded region의 저수량을 초과하였다고 표시함 */
                isOverflowing[ithCellIdx] = TRUE;
            }

            /* (C) flooded region의 초과 유입량을 더함 */
            upstreamDischarge1[ithCellIdx] 
                = upstreamDischarge1[ithCellIdx] + inputDischarge[ithCellIdx];

            /* B. 상부 유역으로부터 유입하는 셀의 갯수를 더함
             * * 주의: i 번째 셀이 유출구이므로 flooded region의 셀 수도 포함함 */
            /* upstreamCellsNo[ithCellIdx] = upstreamCellsNo[ithCellIdx]
             *     + inputCellsNo[ithCellIdx] + floodedRegionCellsNo[ithCellIdx]; */

            /* C. 유량과 셀의 개수를 유향을 따라 다음 셀에 분배함
             * A) 다음 셀 색인
            /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;

            /* B) 다음 셀이 flooded region에 해당하는지 확인해보고, flooded
             *    region에 해당한다면 상부 유역으로부터의 유량과 누적 셀 개수를
             *    flooded region의 유입량에 반영하고, 아니라면 다음 셀의 유입량에
             *    반영함 */

            /* (A) 다음 셀이 flooded region에 해당하는지 확인함 */
            if  ( (int) flood[next] == FLOODED )
            {
                /* a. 다음 셀이 flooded region이라면, 유량과 누적 셀 개수를
                 *    flooded region의 유입량으로 반영함
                 * * 주의 : 유량과 셀의 개수의 처리 방식이 다름 */

                /* a) flooded region의 유출구 색인 */
                /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                outlet = (mwIndex) mexSDSNbrIndicies[next] - 1;

                /* b) 유량을 더할 때는 flooded region의 유입량에 기록함 */
                dischargeInputInFloodedRegion[outlet]
                    = dischargeInputInFloodedRegion[outlet]
                    + upstreamDischarge1[ithCellIdx];

                /* c) 누적 셀 개수를 더할 때는 유출구의 유입량에 기록함 */
                /* inputCellsNo[outlet] 
                /*     = inputCellsNo[outlet] + upstreamCellsNo[ithCellIdx]; */
            }
            else
            {
                /* b. 다음 셀이 flooded region이 아니라면, 다음 셀의 유입량에
                 *    상부 유역으로부터의 유량과 누적 셀 개수를 더함 */
                inputDischarge[next]
                    = inputDischarge[next] + upstreamDischarge1[ithCellIdx];

                /* inputCellsNo[next] 
                /*     = inputCellsNo[next] + upstreamCellsNo[ithCellIdx]; */
            }
        } /* if (floodedRegionCellsNo[ithCellIdx] == 0) */
    } /* for ithCell */
}
