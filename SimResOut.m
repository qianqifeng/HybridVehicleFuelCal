%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               SimResOut.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               05-May-2019 
 % @brief              Output the fig to excel  
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
 % @brief Output the fig to excel  
 % @param hArray: (Engine speed vector)                         rpm
 % @arg h = figure,and you can input the figure handle h to this function
 % @retval no retval
%}
function SimResOut(hArray,auto)
    % Excel file name and path
    filespath = [pwd,'\','SimResults',auto.user.vehConfig,'.xls'];
    % Determine if Excel is open, if it is already open, operate in the open Excel
    try
        xls = actxGetRunningServer('Excel.Application');
    catch
        xls = actxserver('Excel.Application');
    end
    % Set the Excel property to visible
    set(xls, 'Visible', 1);
    % Return to Excel workbook handle
    handleXls = xls.Workbooks;
    % If the test file exists, open the test file, otherwise, create a new and save it. The file name is SimResults.xls
    if exist(filespath,'file')
        Workbook = invoke(handleXls,'Open',filespath);
    else
        Workbook = invoke(handleXls, 'Add');
        Workbook.SaveAs(filespath);
    end
    % Return worksheet handle
    Sheets = xls.ActiveWorkBook.Sheets;
    % Return the first table handle
    sheetfig = get(Sheets, 'Item', 1);
    % Activate the fig table
    invoke(sheetfig, 'Activate');
    % If there is a graphic in the current worksheet, delete the graphic by loop
    Shapes = xls.ActiveSheet.Shapes;
    if Shapes.Count ~= 0
        for i = 1:Shapes.Count
            Shapes.Item(1).Delete;
        end
    end
    for i = 1:length(hArray)
        hgexport(hArray(i), '-clipboard');
        % Paste the graphic into the A5:B5 column of the current form
        xls.ActiveSheet.Range('A5:B5').Select;
        xls.ActiveSheet.Paste;
    end