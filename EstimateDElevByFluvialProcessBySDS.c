/*
 * EstimateDElevByFluvialProcessBySDS.c
 *
 * version 0.3
 *
 * flooded region�� ������ ������ �������, ��õ�� ���� ������ �β� ��
 * ��ݾ� �� ��ȭ���� D8 ������ ���� ���ϴ� �Լ�. FluvialProcess �Լ�(ver 0.8)
 * �� for �ݺ������� C �� ������
 * 
 * [dSedimentThick ...          0 ������ �β� ��ȭ�� [m/subDT]
 * ,dBedrockElev ...            1 ��ݾ� ��ȭ�� [m/subDT]
 * ,dChanBedSed ...             2 �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]
 * ,inputFlux ...               3 ��� �������� ������ ������ [m^3/subDT]
 * ,outputFlux...               4 �Ϸ����� ������ [m^3/subDT]
 * ,inputFloodedRegion ...      5 flooded region������ ������ [m^3/subDT]
 * ,isFilled ...                6 flooded region�� ���� ����
 * ] = EstimateDElevByFluvialProcess ...
 * (dX ...                      0 . �� ũ��
 * ,mRows ...                   1 . �� ����
 * ,nCols ...                   2 . �� ����
 * ,consideringCellsNo)         3 . ��õ�ۿ��� �߻��ϴ� �� ��
 *----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
 * mexSortedIndicies ...        4 . �������� ���ĵ� ����
 * mexSDSNbrIndicies ...        9 . ���� �� ����
 * flood ...                    10 . flooded region
 * floodedRegionCellsNo ...     11 . flooded region ���� �� ��
 * floodedRegionStorageVolume . 12 . flooded region ���差
 * bankfullWidth ...            13 . ���������� ����
 * transportCapacity ...        14 . ������ ��ݴɷ�
 * bedrockIncision ...          15 . ��ݾ� �ϻ� ħ����
 * chanBedSed ...               16 . �ϵ� �� �ϻ� ������ �β�
 * sedimentThick ...            17 . ������ �β�
 * hillslope ...                18 . ��� ��
 * transportCapacityForShallow  19 . ��ǥ����� ���� �����̵�
 * bedrockElev                  20 . ��ݾ� ��
 *------------------------------------------------------------------------- 
 *
 * ������ ��
 * - 20140505
 *  - dBedrockElev ���� ���� �߰���
 * - 20101227
 *  - ��ǥ����� ���� �����̵��� ������
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
    /* ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
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
    
    /* ���� ��ƾ ���� */
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
    /* �ӽ� ���� ���� */
    mwIndex ithCell,ithCellIdx,outlet,next;
    double excessTransportCapacity,tmpBedElev,outputFluxToNext;
    
    const double FLOODED = 2; /* flooded region */
    const double CELL_AREA = dX * dX;
            
    /* (���� �� ������) ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� �� ��ȭ���� ���� */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {        
        /* 1. i��° �� �� ���� ���� ����
         * *  ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;
        next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;

        /* 2. i���� ���� �������� ���ϰ�, �̸� ������ ���� ���� ���� �й��� */
        /* 1) i��° ���� flooded region�� ���ⱸ������ Ȯ���� */
        if ((mwSize) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* (1) flooded region������ ������ ���Է��� flooded region��
             *     ���差�� �ʰ��ϴ��� Ȯ���� */
            if (inputFloodedRegion[ithCellIdx] 
                    > floodedRegionStorageVolume[ithCellIdx])
            {
                /* A. �ʰ��� ���, �ʰ����� ���ⱸ�� �������� ���� */
                inputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                    + (inputFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx]);

                /* B. flooded region�� ������ �������� ä�����ٰ� ǥ���� */
                isFilled[ithCellIdx] = true;
            }
        }
            
        /* 2) i��° ���� ��������� Ȯ���� */
        if (hillslope[ithCellIdx] == true)                
        {
        
            /* (1) ����̶��, ��ǥ���⿡ ���� ħ�ķ��� ���� */
            outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];                
            dSedimentThick[ithCellIdx] 
                    = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
            
            /* to do: ��ݾ� ������ ������ ���� �ʴ� ������ ó���� */
            if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
            {
                dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                outputFlux[ithCellIdx] = sedimentThick[ithCellIdx] * CELL_AREA;
            }            
        }            
        else
        {
            /* (2) ��õ�̶��, ��õ�� ���� ������� ���ϰ� �̸� ���� ���� �й��� */

            /* A. ������ ��ݴɷ�[m^3/subDT]�� �ϵ� �� �ϻ� ���������� ū ���� Ȯ���� */
            excessTransportCapacity /* ���Է� ���� ������ ��ݴɷ� [m^3/subDT] */
                = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];
            if (excessTransportCapacity <= chanBedSed[ithCellIdx])
            {
                /* (A) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ�, �������ȯ���� */
                /* a. ���� ������ ����� [m^3/subDT] */
                outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                /* b. ������ �β� ��ȭ�� [m/subDT] */
                dSedimentThick[ithCellIdx] 
                    = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                /* c. �ϵ� �� �ϻ� ������ ���� [m^3] */
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
                /* (B) ������ ��ݴɷ��� �ϻ� ���������� ũ�� �и�����ȯ���� */
                /* ��ݾ� �Ͻķ� [m/subDT] */
                /* * ����: ���� ���� ��ݾ� �ϻ� ���� ����Ͽ� ��ݾ� �Ͻķ��� �����ϴ� ���� �߰��� */
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

                /* ���� ������ ������ [m^3/subDT] */
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
                /* �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT] */
                dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;
                
                /* for debug */
                if (outputFlux[ithCellIdx] < 0)
                {
                    mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                }
            }
        }

        /* 3. SDS ������ ���� ���� ���� �������� �������� ���� */
        /* A. ���� ���� ��ݵ� ������ ������ [m^3/subDT]*/
        outputFluxToNext = outputFlux[ithCellIdx];
        /* B) ���� ���� flooded region�̶�� inputFloodedRegion��
         *    �������� �ݿ��ϰ� �׷��� �ʴٸ� ���� ���� ���� �ݿ��� */
        if ((mwSize) flood[next] == FLOODED)
        {
            /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
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