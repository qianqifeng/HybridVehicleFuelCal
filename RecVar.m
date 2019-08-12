%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               RecVar.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               23-April-2019 
 % @brief              Record variables in a loop function
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @attention
 %
 %THE PRESENT SCRIPT IS FOR GUIDANCE ONLY AIMS AT PROVIDING DEVELOPER WITH
 %CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
 %TIME. AS A RESULT, OUR TEAM SHALL NOT BE HELD LIABLE FOR ANY DIRECT, 
 %INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
 %FROM THE CONTENT OF SUCH SCRIPT AND/OR THE USE MADE BY CUSTOMERS OF THE
 %CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
 %
 %COPYRIGHT 2019 JLUHybrid
%}

%{
 % @brief  Record variables in a loop function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        var:  the variable need to be recorded
 %       
 % @retval recVar   the variable record matrix
%}
function RecVar(count,var)
    global recVarGlobal
    recVarGlobal(count) = var;
end