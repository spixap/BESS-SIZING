%% ----------------------\\\ SAVING FIGURE \\\-----------------------------
%
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\EVENTS\THESIS\Figures\Chapter_02\J2_appendix';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = get(FigHandle,'Name');
    

pos = get(gcf,'Position');
set(gcf,'PaperSize',[pos(3) pos(4)],'PaperUnits','inches')
print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf')

% print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf','-fillpage')

end
%}