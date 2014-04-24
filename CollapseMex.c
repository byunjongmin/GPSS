/*
 * CollapseMex.c
 *
 * ���� �� ������ Ȱ���� ���� �Ҿ����� ������ ���� ������ ��������
 * ��ݾ� �� �� ������ �β� ��ȭ���� ���ϴ� �Լ� 
 * * ����: Collapse �Լ��� while �ݺ������� MEX ���Ϸ� ������
 * 
 * dSedimentThickByIthCell ...      0 . i��° �Ҿ��� ���� ���� ������ �β� ��ȭ�� [m/dT]
 * = CollapseMex ...
 * (mRows ...                       0 . �� ����
 * ,nCols ...                       1 . �� ����
 * ,isStable ...                    2 . ���� ������ �����̵��� �ʴ� ����ȭ ����
 * ,isBoundary ...                  3 . ������ �̵��� �ܰ� ��� ���� ����
 * ,nextY ...                       4 . ���� ���� Y ��ǥ
 * ,nextX ...                       5 . ���� ���� X ��ǥ
 * ,rapidMassMovementType ...       6 . Ȱ�� ����
 * ,dElev1)                         7 . i��° ���� ħ���� [m/dT]
 *
 *----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
 *
 * dSedimentThickByIthCell          8 . i��° �Ҿ��� ���� ���� ������ �β� ��ȭ�� [m/dT]
 * SDSNbrY ...                      9 . ���� �� Y ��ǥ
 * SDSNbrX ...                      10. ���� �� X ��ǥ
 * elev ...                         11. ���ŵ� ��ǥ �� [m]
 * soilCriticalHeight ...           12. õ��Ȱ���� ���� ���� [m]
 * sedimentThick ...                13. ������ �β�
 * oversteepSlopes ...              14. ���� ��鰢 �ʰ� ��
 * flood ...                        15. flooded region
 
 *
 */
# include "mex.h"

/* ��� �Լ� ���� */
void CollapseMex(
    mwSize mRows,
    mwSize nCols,
    bool isStable,
    bool isBoundary,
    mwIndex nextY,
    mwIndex nextX,
    mwIndex rapidMassMovementType,
    double dElev1,
    double * SDSNbrY,
    double * SDSNbrX,
    double * elev,
    double * soilCriticalHeight,
    double * sedimentThick,
    double * oversteepSlopes,
    double * flood,
    double * dSedimentThickByithCell);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* �Է� ���� ����
     * ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
    /* ȣ���Լ� �۾������� ���� */
    const mxArray * mxArray9;   /* for SDSNbrY */
    const mxArray * mxArray10;  /* for SDSNbrX */
    const mxArray * mxArray11;  /* for elev */
    const mxArray * mxArray12;  /* for soilCriticalHeight */
    const mxArray * mxArray13;  /* for sedimentThick */
    const mxArray * mxArray14;  /* for oversteepSlopes */
    const mxArray * mxArray15;  /* for flood */

    /* ��� ���� ���� */
    mxArray * mxArray8;         /* for dSedimentThickByIthCell */
    
    /* �Էº��� ���� �ڷ�  */
    mwSize mRows;
    mwSize nCols;
    bool isStable;
    bool isBoundary;
    mwIndex nextY;
    mwIndex nextX;
    mwIndex rapidMassMovementType;
    double dElev1;
    
    double * SDSNbrY;
    double * SDSNbrX;
    double * elev;
    double * soilCriticalHeight;
    double * sedimentThick;
    double * oversteepSlopes;
    double * flood;
        
    /* ��� ���� ���� */
    double * dSedimentThickByIthCell;
    
    /* �Էº��� �ʱ�ȭ */
    mRows = (mwSize) mxGetScalar(prhs[0]);
    nCols = (mwSize) mxGetScalar(prhs[1]);
    isStable = (bool) mxGetScalar(prhs[2]);
    isBoundary = (bool) mxGetScalar(prhs[3]);
    nextY = (mwIndex) mxGetScalar(prhs[4]);
    nextX = (mwIndex) mxGetScalar(prhs[5]);
    rapidMassMovementType = (mwIndex) mxGetScalar(prhs[6]);
    dElev1 = mxGetScalar(prhs[7]);
            
    mxArray9    = mexGetVariablePtr("caller","SDSNbrY");
    mxArray10   = mexGetVariablePtr("caller","SDSNbrX");
    mxArray11   = mexGetVariablePtr("caller","elev");
    mxArray12   = mexGetVariablePtr("caller","soilCriticalHeight");
    mxArray13   = mexGetVariablePtr("caller","sedimentThick");
    mxArray14   = mexGetVariablePtr("caller","oversteepSlopes");
    mxArray15   = mexGetVariablePtr("caller","flood");
    
    SDSNbrY                 = mxGetPr(mxArray9);
    SDSNbrX                 = mxGetPr(mxArray10);
    elev                    = mxGetPr(mxArray11);
    soilCriticalHeight      = mxGetPr(mxArray12);
    sedimentThick           = mxGetPr(mxArray13);
    oversteepSlopes         = mxGetPr(mxArray14);
    flood                   = mxGetPr(mxArray15);
    
    /* ��� ���� �ʱ�ȭ */
    /* ȣ�� �Լ��� �۾� ������ �ִ� ������ �����ؼ� �ҷ��� */
    mxArray8 = mexGetVariable("caller","dSedimentThickByIthCell"); 
    plhs[0] = mxArray8;
    
    /* ��� ������ �ڷῡ �����͸� ���� */
    dSedimentThickByIthCell = mxGetPr(plhs[0]);    
    
    /* ���� ��ƾ ���� */
    CollapseMex(
        mRows,
        nCols,
        isStable,
        isBoundary,
        nextY,
        nextX,
        rapidMassMovementType,
        dElev1,
        SDSNbrY,
        SDSNbrX,
        elev,
        soilCriticalHeight,
        sedimentThick,
        oversteepSlopes,
        flood,
        dSedimentThickByIthCell);
}

void CollapseMex(
    mwSize mRows,
    mwSize nCols,
    bool isStable,
    bool isBoundary,
    mwIndex nextY,
    mwIndex nextX,
    mwIndex rapidMassMovementType,
    double dElev1,
    double * SDSNbrY,
    double * SDSNbrX,
    double * elev,
    double * soilCriticalHeight,
    double * sedimentThick,
    double * oversteepSlopes,
    double * flood,
    double * dSedimentThickByIthCell)
{
   /* ��� ���� */ 
   const mwIndex FLOODED = 2;
   const mwIndex SOIL = 1;
   
   mwIndex Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND;
   
   /* �ӽ� ���� ���� */
   mwIndex currentIdx,nextIdx,y,x;
   double dElev2;
   
   Y_TOP_BND = 1;
   Y_BOTTOM_BND = mRows;
   X_LEFT_BND = 1;
   X_RIGHT_BND = nCols; 
   
   /* �� ���� ���� ����� �Ǳ��� �Ǵ� �ܰ� ��迡 �����ϱ� ������ ���� ����
    * ����ۿ��� �ݺ��� */
   while ((isStable == false) && (isBoundary == false))
   {
       /* 1. ���� ���� �� ���� ������ */
       y = nextY;
       x = nextX;
       
       /* �� ���� ���� */
       /* * ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
       currentIdx = (mwIndex) (x-1) * mRows + y - 1;
               
       nextY = (mwIndex) SDSNbrY[currentIdx];
       nextX = (mwIndex) SDSNbrX[currentIdx];
       
       /* ���� ���� ���� */
       /* * ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
       nextIdx = (mwIndex) (nextX-1) * mRows + nextY - 1;

        /* 2. Ȱ������ ���� �� �������� ħ���� ����
         * ����: ���⼭�� (�̵����� �����ϱ� ����) ���� ���� ��ǥ����
         * ���ϵ�. �������� ��ݾ�Ȱ���� �߻��Ͽ����� ����Ϻο����� ������
         * ���� �̵��� ��ݾ�Ȱ������ ������ �ٸ��� ���� ��ݾ�Ȱ��������
         * ������ ���� �� �� �Ӱ� ������ ������� ����. */
        dElev2 = -(((elev[currentIdx] - dElev1) - elev[nextIdx])
            - soilCriticalHeight[currentIdx]);

        /* 3. ���ǿ� ���� ħ������ ������
         * ����: ���� ���� ���� �� �������� ��鹰�� �̵����� ���� �����.
         * ���� ������ ��ȿ ���� ���Ѻ��� �� ���� ���� �̵��Ǿ�� ��.
         * * ����: ���� ���� �ܰ� ����� ������ ������, ���� �̵��� ������.
         * * ����: ���� ���� �Ҿ����� ���� ��쿡�� ���� �������� ���� �̵���
         *   ���� ������ ����ǹǷ� ������ ���� */                                          

        /* ������ ħ������ ���� */
        dElev2 = dElev2 * 0.5;

        if ((nextY == Y_TOP_BND) || (nextY == Y_BOTTOM_BND)
            || (nextX == X_LEFT_BND) || (nextX == X_RIGHT_BND))
        {
            dElev2 = dElev2 * 2;
            
            if (dElev2 < 0)
            {
                /* ����: õ��Ȱ���� ���, �̵����� ������ �β��� ���ѵ� */
                if ((rapidMassMovementType == SOIL)
                    && (- dElev2 > sedimentThick[currentIdx]))
                {
                    dElev2 = dElev1 - sedimentThick[currentIdx];
                }

                dSedimentThickByIthCell[nextIdx] = dSedimentThickByIthCell[nextIdx] - dElev2;
            }
            isBoundary = true;        
        } /* if (nextY == */
        else if (oversteepSlopes[nextIdx] == true)
        {
            dElev2 = dElev2 * 2;
        } /* if (nextY == */
        
        /* ����: (��� �Ϻ��� ���� �̵�����) �̵����� ������ �β��� ���ѵ� */
        if (- dElev2 > sedimentThick[currentIdx])
        {
            dElev2 = dElev1 - sedimentThick[currentIdx];
        }

        /* 4. ���� ���� �� ��ȭ�� */
        if ((dElev2 >= 0) || (flood[currentIdx] == FLOODED))
        {
            /* ���� ������ �̵��� �Ͼ�� �ʴ� ���� ����̰ų�, flooded
             * region�̶�� ������ �β� ��ȭ���� ���ϰ� ���� �̵��� ������ */
            dSedimentThickByIthCell[currentIdx] = dSedimentThickByIthCell[currentIdx] - dElev1;
            
            isStable = true;
        }
        else if (- dElev1 >= - dElev2)
        {
            /* ������ ���� ������ ���� �̵��� �߻��Ѵٸ� ���� ������ �̵�����
             * ����� ������ �β� ��ȭ���� ����		 */
            dSedimentThickByIthCell[currentIdx]
                = dSedimentThickByIthCell[currentIdx] - dElev1 + dElev2;
            
            dElev1 = dElev2;

        /* else  - dElev1 < - dElev2
         
            * �� ���� ���� �Ҿ����� ���̾��ٸ�, ���� ithCell���� ó���ϵ��� �ǳʶ� */            
        } /* if (dElev2 >= 0) */
   } /* while (~isStable */
} /* void Collapse */