/*
 * EstimateDElevByFluvialProcessBySDS.c
 *
 * version 0.3
 *
 * flooded region을 제외한 셀들을 대상으로, 하천에 의한 퇴적층 두께 및
 * 기반암 고도 변화율을 D8 유향을 따라 구하는 함수. FluvialProcess 함수(ver 0.8)
 * 내 for 반복문만을 C 로 변경함
 * 
 * [dSedimentThick ...          0 퇴적층 두께 변화율 [m/subDT]
 * ,dBedrockElev ...            1 기반암 변화율 [m/subDT]
 * ,dChanBedSed ...             2 하도 내 하상 퇴적물 변화율 [m^3/subDT]
 * ,inputFlux ...               3 상부 유역으로 부터의 유입율 [m^3/subDT]
 * ,outputFlux...               4 하류로의 유출율 [m^3/subDT]
 * ,inputFloodedRegion ...      5 flooded region으로의 유입율 [m^3/subDT]
 * ,isFilled ...                6 flooded region의 매적 유무
 * ] = EstimateDElevByFluvialProcess ...
 * (dX ...                      0 . 셀 크기
 * ,mRows ...                   1 . 행 개수
 * ,nCols ...                   2 . 열 개수
 * ,consideringCellsNo)         3 . 하천작용이 발생하는 셀 수
 *----------------------------- mexGetVariablePtr 함수로 참조하는 변수
 * mexSortedIndicies ...        4 . 고도순으로 정렬된 색인
 * mexSDSNbrIndicies ...        9 . 다음 셀 색인
 * flood ...                    10 . flooded region
 * floodedRegionCellsNo ...     11 . flooded region 구성 셀 수
 * floodedRegionStorageVolume . 12 . flooded region 저장량
 * bankfullWidth ...            13 . 만제유량시 하폭
 * transportCapacity ...        14 . 퇴적물 운반능력
 * bedrockIncision ...          15 . 기반암 하상 침식율
 * chanBedSed ...               16 . 하도 내 하상 퇴적층 두께
 * sedimentThick ...            17 . 퇴적층 두께
 * hillslope ...                18 . 사면 셀
 * transportCapacityForShallow  19 . 지표유출로 인한 물질이동
 * bedrockElev                  20 . 기반암 고도
 *------------------------------------------------------------------------- 
 *
 * 개선한 점
 * - 20140505
 *  - dBedrockElev 제한 조건 추가함
 * - 20101227
 *  - 지표유출로 인한 물질이동을 포함함
 * 
 */

#include "mex.h"
#include "matrix.h"

/* computational routine */
void EstimateDElevByFluvialProcessBySDS(
    double * dSedimentThick,                /* output 0 */
    double * dBedrockElev,                  /* output 1 */
    double * dChanBedSed,                   /* output 2 */
    double * inputFlux,                     /* output 3 */
    double * outputFlux,                    /* output 4 */
    double * inputFloodedRegion,            /* output 5 */
    mxLogical * isFilled,                   /* output 6 */
    double dX,                              /* input 0 */
    double consideringCellsNo,              /* input 3 */
    double * mexSortedIndicies,             /* input 4 */
    double * mexSDSNbrIndicies,             /* input 9 */
    double * flood,                         /* input 10 */
    double * floodedRegionCellsNo,          /* input 11 */
    double * floodedRegionStorageVolume,    /* input 12 */
    double * bankfullWidth,                 /* input 13 */
    double * transportCapacity,             /* input 14 */
    double * bedrockIncision,               /* input 15 */
    double * chanBedSed,                    /* input 16 */
    double * sedimentThick,                 /* input 17 */
    mxLogical * hillslope,                  /* input 18 */
    double * transportCapacityForShallow,   /* input 19 */
    double * bedrockElev);                  /* input 20 */

/* gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* check for proper number of arguments */
    /* validate the input values */
    
    /* variable declaration */
    
    /* input variable declaration */
    double dX;
    double mRows;
    double nCols;
    double consideringCellsNo;
    /* 주의: mxArray 자료형 변수는 mexGetVariablePtr 함수를 이용하여
     * 호출함수의 작업공간에 있는 변수들의 포인터만 불러옴 */
    const mxArray * mxArray4;
    const mxArray * mxArray9;
    const mxArray * mxArray10;
    const mxArray * mxArray11;
    const mxArray * mxArray12;
    const mxArray * mxArray13;
    const mxArray * mxArray14;
    const mxArray * mxArray15;
    const mxArray * mxArray16;
    const mxArray * mxArray17;
    const mxArray * mxArray18;
    const mxArray * mxArray19;
    const mxArray * mxArray20;
    
    double * mexSortedIndicies;
    double * mexSDSNbrIndicies;
    double * flood;
    double * floodedRegionCellsNo;
    double * floodedRegionStorageVolume;
    double * bankfullWidth;
    double * transportCapacity;
    double * bedrockIncision;
    double * chanBedSed;
    double * sedimentThick;
    mxLogical * hillslope;
    double * transportCapacityForShallow;
    double * bedrockElev;
    
    /* output variable declaration */
    double * dSedimentThick;
    double * dBedrockElev;
    double * dChanBedSed;
    double * inputFlux;
    double * outputFlux;
    double * inputFloodedRegion;
    mxLogical * isFilled;

    /* create a pointer to the real data in the input matrix */
    dX                  = mxGetScalar(prhs[0]);
    mRows               = mxGetScalar(prhs[1]);
    nCols               = mxGetScalar(prhs[2]);
    consideringCellsNo  = mxGetScalar(prhs[3]);
    
    mxArray4 = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray9 = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray10 = mexGetVariablePtr("caller","flood");
    mxArray11 = mexGetVariablePtr("caller","floodedRegionCellsNo");
    mxArray12 = mexGetVariablePtr("caller","floodedRegionStorageVolume");
    mxArray13 = mexGetVariablePtr("caller","bankfullWidth");
    mxArray14 = mexGetVariablePtr("caller","transportCapacity");
    mxArray15 = mexGetVariablePtr("caller","bedrockIncision");
    mxArray16 = mexGetVariablePtr("caller","chanBedSed");
    mxArray17 = mexGetVariablePtr("caller","sedimentThick");
    mxArray18 = mexGetVariablePtr("caller","hillslope");
    mxArray19 = mexGetVariablePtr("caller","transportCapacityForShallow");
    mxArray20 = mexGetVariablePtr("caller","bedrockElev");
    
    mexSortedIndicies              = mxGetPr(mxArray4);
    mexSDSNbrIndicies              = mxGetPr(mxArray9);    
    flood                          = mxGetPr(mxArray10);    
    floodedRegionCellsNo           = mxGetPr(mxArray11);    
    floodedRegionStorageVolume     = mxGetPr(mxArray12);    
    bankfullWidth                  = mxGetPr(mxArray13);
    transportCapacity              = mxGetPr(mxArray14);    
    bedrockIncision                = mxGetPr(mxArray15);
    chanBedSed                     = mxGetPr(mxArray16);
    sedimentThick                  = mxGetPr(mxArray17);
    hillslope                      = mxGetLogicals(mxArray18);
    transportCapacityForShallow    = mxGetPr(mxArray19);
    bedrockElev                    = mxGetPr(mxArray20);

    /* prepare output data */
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[4] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[5] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[6] = mxCreateLogicalMatrix(mRows,nCols);
    
    /* get a pointer to the real data in the output matrix */
    dSedimentThick      = mxGetPr(plhs[0]);
    dBedrockElev        = mxGetPr(plhs[1]);
    dChanBedSed         = mxGetPr(plhs[2]);
    inputFlux           = mxGetPr(plhs[3]);
    outputFlux          = mxGetPr(plhs[4]);
    inputFloodedRegion  = mxGetPr(plhs[5]);
    isFilled            = mxGetLogicals(plhs[6]);
    
    /* 서브 루틴 수행 */
    EstimateDElevByFluvialProcessBySDS(
        dSedimentThick,
        dBedrockElev,
        dChanBedSed,
        inputFlux,
        outputFlux,
        inputFloodedRegion,
        isFilled,
        dX,
        consideringCellsNo,
        mexSortedIndicies,
        mexSDSNbrIndicies,
        flood,
        floodedRegionCellsNo,
        floodedRegionStorageVolume,
        bankfullWidth,
        transportCapacity,
        bedrockIncision,
        chanBedSed,
        sedimentThick,
        hillslope,
        transportCapacityForShallow,
        bedrockElev);

}

void EstimateDElevByFluvialProcessBySDS(
    double * dSedimentThick,
    double * dBedrockElev,
    double * dChanBedSed,
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mxLogical * isFilled,
    double dX,
    double consideringCellsNo,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume,
    double * bankfullWidth,
    double * transportCapacity,
    double * bedrockIncision,
    double * chanBedSed,
    double * sedimentThick,
    mxLogical * hillslope,
    double * transportCapacityForShallow,
    double * bedrockElev)
{
    /* 임시 변수 선언 */
    mwIndex ithCell,ithCellIdx,outlet,next;
    double excessTransportCapacity,tmpBedElev,outputFluxToNext;
    
    const double FLOODED = 2; /* flooded region */
    const double CELL_AREA = dX * dX;
            
    /* (높은 고도 순으로) 하천작용에 의한 퇴적물 두께 및 기반암 고도 변화율을 구함 */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {        
        /* 1. i번째 셀 및 다음 셀의 색인
         * *  주의: MATLAB 배열 선형 색인을 위해 '-1'을 수행함 */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;
        next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;

        /* 2. i번재 셀의 유출율을 구하고, 이를 유향을 따라 다음 셀에 분배함 */
        /* 1) i번째 셀이 flooded region의 유출구인지를 확인함 */
        if ((mwSize) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* (1) flooded region으로의 퇴적물 유입량이 flooded region의
             *     저장량을 초과하는지 확인함 */
            if (inputFloodedRegion[ithCellIdx] 
                    > floodedRegionStorageVolume[ithCellIdx])
            {
                /* A. 초과할 경우, 초과량을 유출구의 유입율에 더함 */
                inputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                    + (inputFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx]);

                /* B. flooded region이 유입한 퇴적물로 채워졌다고 표시함 */
                isFilled[ithCellIdx] = true;
            }
        }
            
        /* 2) i번째 셀이 사면인지를 확인함 */
        if (hillslope[ithCellIdx] == true)                
        {
        
            /* (1) 사면이라면, 지표유출에 의한 침식률을 구함 */
            outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];                
            dSedimentThick[ithCellIdx] 
                    = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
            
            /* to do: 기반암 고도에는 영향을 주지 않는 것으로 처리함 */
            if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
            {
                dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                outputFlux[ithCellIdx] = sedimentThick[ithCellIdx] * CELL_AREA;
            }            
        }            
        else
        {
            /* (2) 하천이라면, 하천에 의한 유출률을 구하고 이를 다음 셀에 분배함 */

            /* A. 퇴적물 운반능력[m^3/subDT]이 하도 내 하상 퇴적물보다 큰 지를 확인함 */
            excessTransportCapacity /* 유입량 제외 퇴적물 운반능력 [m^3/subDT] */
                = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];
            if (excessTransportCapacity <= chanBedSed[ithCellIdx])
            {
                /* (A) 퇴적물 운반능력이 하상 퇴적물보다 작다면, 운반제어환경임 */
                /* a. 다음 셀로의 유출률 [m^3/subDT] */
                outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                /* b. 퇴적층 두께 변화율 [m/subDT] */
                dSedimentThick[ithCellIdx] 
                    = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                /* c. 하도 내 하상 퇴적층 부피 [m^3] */
                dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;

                /* for debug */
                if (sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx] < 0)
                {
                    mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeSedimentThick","negative sediment thickness");
                }
                if (outputFlux[ithCellIdx] < 0)
                {
                    mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                }
            }
            else
            {
                /* (B) 퇴적물 운반능력이 하상 퇴적물보다 크면 분리제어환경임 */
                /* 기반암 하식률 [m/subDT] */
                /* * 주의: 다음 셀의 기반암 하상 고도를 고려하여 기반암 하식률을 산정하는 것을 추가함 */
                dBedrockElev[ithCellIdx] = - (bedrockIncision[ithCellIdx] / CELL_AREA);
                /* prevent bedrock elevation from being lowered compared to downstream node */
                tmpBedElev = bedrockElev[ithCellIdx] + dBedrockElev[ithCellIdx];
                if (tmpBedElev < bedrockElev[next])
                {
                    dBedrockElev[ithCellIdx] = bedrockElev[next] - bedrockElev[ithCellIdx];
                    
                    /* for warning and debug */
                    if (dBedrockElev[ithCellIdx] > 0)
                    {
                        /* for the intitial condition in which upstream bedrock
                         * elevation is lower than its downstream */
                        if (bedrockElev[ithCellIdx] < bedrockElev[next])
                        {
                            mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeDBedrockElev"
                                ,"reversed dBedrockElev: diff with next, %f"
                                ,bedrockElev[next] - bedrockElev[ithCellIdx]);
                            dBedrockElev[ithCellIdx] = 0;
                        }
                        else
                        {
                            /* for debug */                                
                            mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeDBedrockElev"
                                    ,"negative dBedrockElev");

                        }                        
                    }
                }   

                /* 다음 셀로의 유출율 [m^3/subDT] */
                outputFlux[ithCellIdx] = inputFlux[ithCellIdx] + chanBedSed[ithCellIdx]
                        - (dBedrockElev[ithCellIdx] * CELL_AREA);
                /* don't include flux due to bedrock incision */
                dSedimentThick[ithCellIdx] = - (inputFlux[ithCellIdx] + chanBedSed[ithCellIdx])
                                                / CELL_AREA;
                if (sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx] < 0)
                {
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                    outputFlux[ithCellIdx]
                            = - (dSedimentThick[ithCellIdx] + dBedrockElev[ithCellIdx]) * CELL_AREA;
                } 
                /* 하도 내 하상 퇴적물 변화율 [m^3/subDT] */
                dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;
                
                /* for debug */
                if (outputFlux[ithCellIdx] < 0)
                {
                    mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                }
            }
        }

        /* 3. SDS 유향을 따라 다음 셀의 유입율에 유출율을 더함 */
        /* A. 다음 셀에 운반될 퇴적물 유출율 [m^3/subDT]*/
        outputFluxToNext = outputFlux[ithCellIdx];
        /* B) 다음 셀이 flooded region이라면 inputFloodedRegion에
         *    유출율을 반영하고 그렇지 않다면 다음 셀에 직접 반영함 */
        if ((mwSize) flood[next] == FLOODED)
        {
            /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
            outlet = (mwIndex) mexSDSNbrIndicies[next] - 1;
            inputFloodedRegion[outlet] /* [m^3/subDT] */
                = inputFloodedRegion[outlet] + outputFluxToNext;
        }
        else /* flood[next] ~= FLOODED */
        {
            inputFlux[next] = inputFlux[next] + outputFluxToNext;
        }

    } /* for ithCell=1:consideringCellsNo */        
} /* void ForFluvialProcess */