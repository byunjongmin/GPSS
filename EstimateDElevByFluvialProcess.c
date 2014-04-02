/*
 * EstimateDElevByFluvialProcess.c
 *
 * version 0.2
 *
 * flooded region을 제외한 셀들을 대상으로, 하천에 의한 퇴적층 두께 및
 * 기반암 고도 변화율을 구하는 함수. FluvialProcess 함수(ver 0.8)의 for
 * 반복문만을 C 로 변경함
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
 * e1LinearIndicies ...         5 . 다음 셀 색인
 * e2LinearIndicies ...         6 . 다음 셀 색인
 * outputFluxRatioToE1 ...      7 . 다음 셀로의 유출 비율
 * outputFluxRatioToE2 ...      8 . 다음 셀로의 유출 비율
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
 *------------------------------------------------------------------------- 
 *
 * 개선한 점
 *
 * - 20101227
 *  - 지표유출로 인한 물질이동을 포함함
 * 
 */

# include "mex.h"

/* 계산 함수 선언 */
void EstimateDElevByFluvialProcess(
    double * dSedimentThick,
    double * dBedrockElev,
    double * dChanBedSed,
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mxLogical * isFilled,
    int dX,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume,
    double * bankfullWidth,
    double * transportCapacity,
    double * bedrockIncision,
    double * chanBedSed,
    double * sedimentThick,
    double * hillslope,
    double * transportCapacityForShallow);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* 입력 변수 선언
     * 주의: mxArray 자료형 변수는 mexGetVariablePtr 함수를 이용하여
     * 호출함수의 작업공간에 있는 변수들의 포인터만 불러옴 */
    /* 호출함수 작업공간의 변수 */
    const mxArray * mxArray4; /* mexSortedIndicies */
    const mxArray * mxArray5; /* e1LinearIndicies */
    const mxArray * mxArray6; /* e2LinearIndicies */
    const mxArray * mxArray7; /* outputFluxRatioToE1 */
    const mxArray * mxArray8; /* outputFluxRatioToE2 */
    const mxArray * mxArray9; /* mexSDSNbrIndicies */
    const mxArray * mxArray10; /* flood */
    const mxArray * mxArray11; /* floodedRegionCellsNo */
    const mxArray * mxArray12; /* floodedRegionStorageVolume */
    const mxArray * mxArray13; /* bankfullWidth */
    const mxArray * mxArray14; /* transportCapacity */
    const mxArray * mxArray15; /* bedrockIncision */
    const mxArray * mxArray16; /* chanBedSed */
    const mxArray * mxArray17; /* sedimentThick */
    const mxArray * mxArray18; /* hillslope */
    const mxArray * mxArray19; /* transportCapacityForShallow */
    
    /* 입력변수 실제 자료  */
    int dX;
    mwSize mRows;
    mwSize nCols;
    mwSize consideringCellsNo;
    double * mexSortedIndicies;
    double * e1LinearIndicies;
    double * e2LinearIndicies;
    double * outputFluxRatioToE1;
    double * outputFluxRatioToE2;
    double * mexSDSNbrIndicies;
    double * flood;
    double * floodedRegionCellsNo;
    double * floodedRegionStorageVolume;
    double * bankfullWidth;
    double * transportCapacity;
    double * bedrockIncision;
    double * chanBedSed;
    double * sedimentThick;
    double * hillslope;
    double * transportCapacityForShallow;
    
    /* 출력 변수 선언 */
    double * dSedimentThick;
    double * dBedrockElev;
    double * dChanBedSed;
    double * inputFlux;
    double * outputFlux;
    double * inputFloodedRegion;
    mxLogical * isFilled;
    
    /* 입력 변수 초기화 */      
    dX                  = (int) mxGetScalar(prhs[0]);
    mRows               = (mwSize) mxGetScalar(prhs[1]);
    nCols               = (mwSize) mxGetScalar(prhs[2]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[3]);
    
    mxArray4    = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray5    = mexGetVariablePtr("caller","e1LinearIndicies");    
    mxArray6    = mexGetVariablePtr("caller","e2LinearIndicies");    
    mxArray7    = mexGetVariablePtr("caller","outputFluxRatioToE1");
    mxArray8    = mexGetVariablePtr("caller","outputFluxRatioToE2");
    mxArray9    = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray10   = mexGetVariablePtr("caller","flood");
    mxArray11   = mexGetVariablePtr("caller","floodedRegionCellsNo");
    mxArray12   = mexGetVariablePtr("caller","floodedRegionStorageVolume");
    mxArray13   = mexGetVariablePtr("caller","bankfullWidth");
    mxArray14   = mexGetVariablePtr("caller","transportCapacity");
    mxArray15   = mexGetVariablePtr("caller","bedrockIncision");
    mxArray16   = mexGetVariablePtr("caller","chanBedSed");
    mxArray17   = mexGetVariablePtr("caller","sedimentThick");
    mxArray18   = mexGetVariablePtr("caller","hillslope");
    mxArray19   = mexGetVariablePtr("caller","transportCapacityForShallow");
    
    mexSortedIndicies           = mxGetPr(mxArray4);    
    e1LinearIndicies            = mxGetPr(mxArray5);    
    e2LinearIndicies            = mxGetPr(mxArray6);    
    outputFluxRatioToE1         = mxGetPr(mxArray7);    
    outputFluxRatioToE2         = mxGetPr(mxArray8);    
    mexSDSNbrIndicies           = mxGetPr(mxArray9);    
    flood                       = mxGetPr(mxArray10);    
    floodedRegionCellsNo        = mxGetPr(mxArray11);    
    floodedRegionStorageVolume  = mxGetPr(mxArray12);    
    bankfullWidth               = mxGetPr(mxArray13);
    transportCapacity           = mxGetPr(mxArray14);    
    bedrockIncision             = mxGetPr(mxArray15);
    chanBedSed                  = mxGetPr(mxArray16);
    sedimentThick               = mxGetPr(mxArray17);
    hillslope                   = mxGetPr(mxArray18);
    transportCapacityForShallow = mxGetPr(mxArray19);
    
    /* 출력 변수 초기화 */
    plhs[0] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[4] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[5] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[6] = mxCreateLogicalMatrix(mRows,nCols);
    
    /* 출력 변수 자료에 포인터를 지정 */
    dSedimentThick = mxGetPr(plhs[0]);
    dBedrockElev = mxGetPr(plhs[1]);
    dChanBedSed = mxGetPr(plhs[2]);
    inputFlux = mxGetPr(plhs[3]);
    outputFlux = mxGetPr(plhs[4]);
    inputFloodedRegion = mxGetPr(plhs[5]);
    isFilled = mxGetLogicals(plhs[6]);
    
    /* 서브 루틴 수행 */
    EstimateDElevByFluvialProcess(
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
        e1LinearIndicies,
        e2LinearIndicies,
        outputFluxRatioToE1,
        outputFluxRatioToE2,
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
        transportCapacityForShallow);

}

void EstimateDElevByFluvialProcess(
    double * dSedimentThick,
    double * dBedrockElev,
    double * dChanBedSed,
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mxLogical * isFilled,
    int dX,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume,
    double * bankfullWidth,
    double * transportCapacity,
    double * bedrockIncision,
    double * chanBedSed,
    double * sedimentThick,
    double * hillslope,
    double * transportCapacityForShallow)
{
    /* 임시 변수 선언 */
    mwIndex ithCell,ithCellIdx,outlet,next,e1,e2;
    double excessTransportCapacity,outputFluxToE1,outputFluxToE2;
    
    const int FLOODED = 2; /* flooded region */
    const int TRUE = 1;
    const int CELL_AREA = dX * dX;
            
    /* (높은 고도 순으로) 하천작용에 의한 퇴적물 두께 및 기반암 고도 변화율을 구함 */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {        
        /* 1. i번째 셀의 색인
         * *  주의: MATLAB 배열 선형 색인을 위해 '-1'을 수행함 */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. i번재 셀의 유출율을 구하고, 이를 유향을 따라 다음 셀에 분배함 */

        /* 1). i번째 셀이 flooded region의 유출구인지를 확인함 */
        if ((int) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            
            /* (1) i번째 셀이 사면인지를 확인함 */
            if ((int) hillslope[ithCellIdx] == TRUE)                
            {
            
                outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];
                
                dSedimentThick[ithCellIdx] 
                        = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                
                if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
                {
                        
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                        
                    outputFlux[ithCellIdx] = sedimentThick[ithCellIdx];                    
                }
            
            }
            
            else
            {
                
                /* A. flooded region의 유출구가 아니라면 하천작용에 의한 유출율을
                 *     구하고 이를 무한 유향을 따라 다음 셀에 분배함 */

                /* A) 초과 퇴적물 운반능력[m^3/subDT]이 하도 내 하상 퇴적물보다 큰 지를 확인함 */
                excessTransportCapacity /* [m^3/subDT] */
                    = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];

                if (excessTransportCapacity > chanBedSed[ithCellIdx])
                {
                    /* (A) 초과 퇴적물 운반능력이 하상 퇴적물보다 크면 분리제어환경임 */

                    /* a. 다음 셀로의 유출율([m^3/subDT])을 구함 */
                    outputFlux[ithCellIdx] = inputFlux[ithCellIdx] 
                        + chanBedSed[ithCellIdx] + bedrockIncision[ithCellIdx];

                    /* b. 분리제어환경 아래 유출율은 퇴적물 운반능력보다는 작음 */
                    if (outputFlux[ithCellIdx] > transportCapacity[ithCellIdx])
                    {
                       outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                    }

                    /* c. 퇴적물 두께 변화율 [m/subDT] */
                    dSedimentThick[ithCellIdx] = - chanBedSed[ithCellIdx]
                        / CELL_AREA;

                    /* d. 기반암 하상 침식율 [m/subDT] */
                    /* 주의: outputFlux가 조정되었을 수 있기 때문에, 아래 수식은
                     * 사용하지 않음 */
                    /* dBedrockElev[ithCellIdx] = - bedrockIncision[ithCellIdx]; */
                    dBedrockElev[ithCellIdx] = - (outputFlux[ithCellIdx]
                        - (chanBedSed[ithCellIdx] + inputFlux[ithCellIdx]))
                        / CELL_AREA;

                    /* e. 하도 내 하상 퇴적물 변화율 [m^3/subDT] */
                    dChanBedSed[ithCellIdx] = - chanBedSed[ithCellIdx];
                }
                else
                {
                    /* (B) 퇴적물 운반능력이 하상 퇴적물보다 작다면, 운반제어환경임 */

                    /* a. 다음 셀로의 유출율 [m^3/subDT] */
                    outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];

                    /* b. 퇴적층 두께 변화율 [m/subDT] */
                    dSedimentThick[ithCellIdx] = (inputFlux[ithCellIdx]
                        - outputFlux[ithCellIdx]) / CELL_AREA;

                    /* c. 하도 내 하상 퇴적층 부피 [m^3] */
                    dChanBedSed[ithCellIdx] = inputFlux[ithCellIdx] 
                            - outputFlux[ithCellIdx];
                }
            }

            /* B. 무한 유향을 따라 다음 셀(e1,e2)의 유입율에 유출율을 더함 */
            
            /* 다음 셀 색인
             * *  주의: MATLAB 배열 선형 색인을 위해 '-1'을 수행함 */
            e1 = (mwIndex) e1LinearIndicies[ithCellIdx] - 1;
            e2 = (mwIndex) e2LinearIndicies[ithCellIdx] - 1;
            
            /* A) 다음 셀에 운반될 퇴적물 유출율 [m^3/subDT]*/
            outputFluxToE1 = outputFluxRatioToE1[ithCellIdx] 
                * outputFlux[ithCellIdx];
            outputFluxToE2 = outputFluxRatioToE2[ithCellIdx]
                * outputFlux[ithCellIdx];

            /* B) 다음 셀이 flooded region이라면 inputFloodedRegion에
             *    유출율을 반영하고 그렇지 않다면 다음 셀에 직접 반영함 */
            if ((int) flood[e1] == FLOODED)
            {
                /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                outlet = (mwIndex) mexSDSNbrIndicies[e1] - 1;                

                inputFloodedRegion[outlet] /* [m^3/subDT] */
                    = inputFloodedRegion[outlet] + outputFluxToE1;
            }
            else /* flood[e1] ~= FLOODED */
            {
                inputFlux[e1] = inputFlux[e1] + outputFluxToE1;
            }
            
            if ((int) flood[e2] == FLOODED)
            {
                /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                outlet = (mwIndex) mexSDSNbrIndicies[e2] - 1;                

                inputFloodedRegion[outlet] /* [m^3/subDT] */
                    = inputFloodedRegion[outlet] + outputFluxToE2;
            }
            else
            {
                inputFlux[e2] = inputFlux[e2] + outputFluxToE2;
            }
        }
        else /* (floodedRegionCellsNo[ithCellIdx] != 0) */
        {
            /* (2) i번째 셀이 flooded region의 유출구라면 무한 유향을
             *     이용하지 않고, 최대하부경사 유향 알고리듬을 이용한다.즉,
             *     SDSNbrY,SDSNbrX가 가리키는 다음 셀로 유출율을 전달함 */

            /* A. flooded region으로의 퇴적물 유입량이 flooded region의
             *    저장량을 초과하는지 확인함 */
            if (inputFloodedRegion[ithCellIdx] 
                    > floodedRegionStorageVolume[ithCellIdx])
            {
                /* A) 초과할 경우, 초과량을 유출구의 유입율에 더함 */
                inputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                    + (inputFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx]);

                /* B) flooded region이 유입한 퇴적물로 채워졌다고 표시함 */
                isFilled[ithCellIdx] = TRUE;
            }
            
            
            /* B. i번째 셀이 사면인지를 확인함 */
            if ((int) hillslope[ithCellIdx] == TRUE)                
            {
            
                outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];
                
                dSedimentThick[ithCellIdx] 
                        = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                
                if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
                {
                        
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                        
                    outputFlux[ithCellIdx] = sedimentThick[ithCellIdx];                    
                }
            
            }
            
            else
            {
                        
                /* A) 초과 퇴적물 운반능력이 하상 퇴적물보다 큰 지를 확인함 */
                excessTransportCapacity /* [m^3/subDT] */
                    = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];

                if (excessTransportCapacity > chanBedSed[ithCellIdx])
                {
                    /* (A) 초과 퇴적물 운반능력이 하상 퇴적물량보다 크면 분리제어환경임 */

                    /* a. 다음 셀로의 유출율 [m^3/subDT] */
                    outputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                        + chanBedSed[ithCellIdx] + bedrockIncision[ithCellIdx];

                    /* b. 분리제어환경 아래 유출율은 퇴적물 운반능력보다는 작음 */
                    if (outputFlux[ithCellIdx] > transportCapacity[ithCellIdx])
                    {
                       outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                    }

                    /* c. 퇴적물 두께 변화율 [m/subDT] */
                    dSedimentThick[ithCellIdx] = - chanBedSed[ithCellIdx]
                        / CELL_AREA;

                    /* d. 기반암 하상 고도 변화율 [m/subDT] */
                    /* 주의: outputFlux가 조정되었을 수 있기 때문에, 아래 수식은
                     * 사용하지 않음 */
                    /* dBedrockElev[ithCellIdx] = - bedrockIncision[ithCellIdx]; */
                    dBedrockElev[ithCellIdx] = - (outputFlux[ithCellIdx]
                        - (chanBedSed[ithCellIdx] + inputFlux[ithCellIdx]))
                        / CELL_AREA;

                    /* e. 하도 내 하상 퇴적물 변화율 [m^3] */
                    dChanBedSed[ithCellIdx] = - chanBedSed[ithCellIdx];

                }
                else
                {
                    /* (B) 퇴적물 운반능력이 하상 퇴적물보다 작다면, 운반제어환경임 */

                    /* a. 다음 셀로의 유출율 */
                    outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];

                    /* b. 퇴적물 두께 변화율 [m/subDT] */
                    dSedimentThick[ithCellIdx] = (inputFlux[ithCellIdx]
                        - outputFlux[ithCellIdx]) / CELL_AREA;

                    /* c. 하도 내 하상 퇴적물 변화율 [m^3] */
                    dChanBedSed[ithCellIdx] = inputFlux[ithCellIdx] 
                            - outputFlux[ithCellIdx];

                }
            }
            
            /* C. 최대하부경사 유향을 따라 다음 셀의 유입율에 유출율을 더함 */
            /* A) 최대 하부 경사 유향이 가리키는 다음 셀의 좌표
            * *  주의: MATLAB 배열 선형 색인을 위해 '-1'을 수행함 */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;            

            /* B) 다음 셀이 flooded region 이라면 inputFloodedRegion에
             *    유출율을 반영하고 그렇지 않다면 다음 셀에 직접 반영함 */
            if  ( flood[next] == FLOODED )
            {
                /* * 주의: MATLAB 배열 색인을 위해 '-1'을 수행함 */
                outlet = (mwIndex) mexSDSNbrIndicies[next];                                

                inputFloodedRegion[outlet] /* [m^3/subDT] */
                    = inputFloodedRegion[outlet] + outputFlux[ithCellIdx];
            }
            else
            {
               inputFlux[next] = inputFlux[next] + outputFlux[ithCellIdx];
            }        
        } /* (floodedRegionCellsNo[ithCellIdx] == 0) */
    } /* for ithCell=1:consideringCellsNo */        
} /* void ForFluvialProcess */