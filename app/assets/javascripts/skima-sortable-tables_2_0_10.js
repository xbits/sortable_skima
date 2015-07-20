//= require jquery-ui.min
//= require jquery.ba-bbq
//these lines above arent working...sprockets gem should make it work but I couldn't figure how to

//creates filters from submit action
//WARNING THIS SHOULD BE IN A DIFFERENT FILE


/**------------SORTABLE TABLE JQUERY PLUGIN-------------------
 * Author: xbits @ skima on 3/21/14.
 *
 * Requires: jquery.js, jquery-ui.js, jquery-ui.css(including images)
 *
 * Requires: The whole fkin gem
 *
 * Description:
 *
 * Jquery plugin for sortable tables
 *
 *
 * Add to a table example:
 *     $('.myTable').sortableTable();
 **/

var SortableLocale = {
    noDataMessage: 'No results found'
}
$(document).ready(function(){
    jQuery.fn.sortableTable = sortableTable;
    $("[data-sortable-query]").sortableTable();//inits sortable tables for the chosen selector

    //change pagination to work by ajax on sortable columns

    function sortableTable(options){
        var QUERY_ATTR = 'data-sortable-query';

        var SORT_ATTR = 'sort-field';//attribute(in each <th>) name of the field to order IE: sortField ='id'
        var SOURCE_ATTR = 'sort-source';//attr(in <table>) name of the path to query, if empty the current domain is queried
        var LINK_ITEM_ATTR = 'data-link-item';
        var PER_PAGE_ATTR = "data-per-page";
        var CLASS_ATTR = 'data-class';
        var INIT_ON_CLIENT_ATTR = "data-initialize-on-client"
        var PRE_SORT_ATTR = 'sort-default';//attr(in <table>) name of currently sorted column IE: 'name ASC'
        var DONT_SORT_ATTR = 'dont-sort';//the attr(in each <th>) for local sorting tables skips sorting on this column
        var LOAD_BY_AJAX_ATTR = 'load-by-ajax';//attr(in <table>) boolean defaults to true, if true only the tbody content will be loaded by an ajax call, else the whole page will be loaded
        var TOKEN_ATTR = 'data-table-token';//unique identifier for this particular query for backtraces
        var GROUP_ID_ATTR = 'data-group-id'//identifier for the groups of related table and filters
        var FILTER_KEY_ATTR = 'data-filter-key'//identifier for the filter column

        var LOCAL_DATA_FLAG = 'useLocalData';//set attr 'sortSource' as this to sort only locally with already available <td> rows

        var ORDER_ATTR = 'sort-order';//for internal use
        var DEF_ORDER = "DESC";//default/initial sort order
        var UP_ICON = "ui-icon-triangle-1-n";
        var DOWN_ICON = "ui-icon-triangle-1-s";

        var EVT_LOADED = 'sortable.loaded';

        options = options || {};

        $(this).each(function(){//create sortable table for all elements returned by jquery's selector
            options = this.sortableTableOptions = $.extend(this.sortableTableOptions, options);
            var $tableElm = $(this);
            var $tBody = $tableElm.find('tbody');
            //  var $filtersForm  = $("["+FILTERS_ID_ATTR+"='"+$tableElm.attr(FILTERS_ID_ATTR)+"']");
            var $filters = $("select["+GROUP_ID_ATTR+"='"+$tableElm.attr(GROUP_ID_ATTR)+"']");
            var $paginateContainer  = $(".paginate-container["+GROUP_ID_ATTR+"='"+$tableElm.attr(GROUP_ID_ATTR)+"']");
            var curField = "";
            var curOrder = "";
            var prevField = "";
            var prevOrder = "";
            var sortBtns = [];
            var loaderDiv;
            // var lastSort = "";
            var useLocalData = false;
            var curPage = 1;
            var fields ={};
            var initialRequest = !($tableElm.attr(INIT_ON_CLIENT_ATTR) == 'true');
            var filtersLock = false;//disables filters lock during update

            init();
            function init (){
                if($tableElm.data('sortableTableInit')){
                    //console.log("This table was already initiated",$tableElm.attr(GROUP_ID_ATTR),$(this))
                    return;
                }
                $tableElm.data('sortableTableInit',true)
                useLocalData = $tableElm.attr(SOURCE_ATTR) == LOCAL_DATA_FLAG;
                var fieldHeaderSelector = (useLocalData)?'th':'th['+SORT_ATTR+']';
                var sortClickMethod = (useLocalData)?sortClickLocal:onSortClickRemote;
                var indexes = [];
                $tableElm.find(fieldHeaderSelector).each(function(){
                    if($(this).html() != '' && !this.sortableTableInit && !$(this).attr(DONT_SORT_ATTR)){
                        this.sortableTableInit = true;//dont add twice
                        if(useLocalData){ $(this).attr(SORT_ATTR, $(this).html());}
                        if($(this).attr(SORT_ATTR)){
                            var curIndex = $(this).position().left;//use x position
                            indexes.push(curIndex);
                            fields[$(this).attr(SORT_ATTR)] = {
                                tmpIndex:curIndex,
                                $element:$(this),
                                linkItem:$(this).attr(LINK_ITEM_ATTR),
                                class: $(this).attr(CLASS_ATTR)
                            }
                        }
                        if(!$(this).attr('disabled')){
                            var btnDiv = document.createElement('div');//add div for css-position fix
                            btnDiv.innerHTML = $(this).html();
                            var rowspan = parseInt($(this).attr('rowspan') || 1)
                            $(this).css('padding',0);
                            $(this).html(btnDiv);
                            $(btnDiv).css('width','100%').css('height',rowspan*1.8+'em');//$(this).height()-2+'px');
                            $(btnDiv).button();
                            $(btnDiv).children().css('line-height',$(this).height()-2+'px');
                            $(btnDiv).click(sortClickMethod);
                            sortBtns.push($(btnDiv));
                        }
                    }
                });
                //Give colindexes sequential values instead of X position
                indexes = indexes.sort(function (a, b) { return a-b; });
                for(var i = 0; i < indexes.length; i++){
                    for(fieldName in fields){
                        if(fields[fieldName].tmpIndex == indexes[i]){
                            fields[fieldName].colIndex = i;
                            delete fields[fieldName].tmpIndex
                            break;
                        }
                    }
                }
                var preSort = $tableElm.attr(PRE_SORT_ATTR);
                if(preSort){
                    preSort = preSort.split(',')[0].split(' ');
                    curField = preSort[0];
                    curOrder = preSort[1];
                    updateArrowDisplay();
                }
                initPagination();
                initFilters();
                autoLoadIfEmpty()
            }
            function initFilters(){
                $filters.change(onFiltersChange);
            }

            function onFiltersChange(){
                if(!filtersLock){
                    curPage = 1;
                    loadAjaxContent(curPage);
                }
            }

            //these two function hijack the pagination links
            function initPagination(){

                $paginateContainer.find('.pagination').first().click(onPaginationClick)
            }
            function onPaginationClick(e){
                //I think most of the code in this method is outdated and useless in current version
                // but its working so I cant be bothered to refactor it! Some day...maybe...
                //try{
                if( $(e.target).attr('href')){
                    var href = $(e.target).attr('href');
                    var paramObj = $.deparam.querystring(href);
                    var newPage = parseInt(paramObj.page);
                    if(newPage != curPage){
                        var $curPageLink = $(this).find('.current');
                        curPage = curPage || $.deparam.querystring().page;
                        paramObj.page = curPage;//set this for old link build
                        var linkUrl = location.pathname+'?'+ $.param(paramObj);
                        var pagelinks = $(this).children();
                        var totalPages = parseInt(pagelinks.eq(pagelinks.length-2).html());
                        $(this).html('');

                        var upperLimit = Math.max(8,newPage+4);
                        for(var i = 1; i <= totalPages; i++){
                            if(i==3 && i < totalPages-8 && i < newPage -4 ){
                                i = Math.min(totalPages-8 , newPage -4);
                                $(this).append('<span class="gap">...</span> ');
                            }else if(i == upperLimit+1 && i < totalPages-2){
                                i = totalPages-1;
                                $(this).append('<span class="gap">...</span> ');
                            }
                            var selectedClass = (i == newPage)?'current':'';
                            paramObj.page = i;
                            linkUrl = location.pathname+'?'+ $.param(paramObj);
                            $(this).append('<a class="'+selectedClass+'" href="'+linkUrl+'">'+i+'</a> ');
                        }

                        paramObj.page = Math.max(1,newPage-1);
                        linkUrl = location.pathname+'?'+ $.param(paramObj);
                        $(this).prepend('<a href="'+linkUrl+'" class="previous_page" rel="prev">⇐ Anterior</a>');
                        paramObj.page = Math.min(totalPages,newPage+1);
                        linkUrl = location.pathname+'?'+ $.param(paramObj);
                        $(this).append('<a href="'+linkUrl+'" class="next_page" rel="next">Próximo ⇒</a>');

                        curPage = newPage;
                        loadFromRemote(newPage);
                    }
                }

                return false;
            }

            function autoLoadIfEmpty(){
                if(!$tBody.html().trim()){
                    !$tBody.html('.');
                    updateArrowDisplay();
                    var loadByAjax = $tableElm.attr(LOAD_BY_AJAX_ATTR);
                    if(loadByAjax != 'false'){
                        loadAjaxContent(curPage);
                    }
                }
            }

            function getNewOrder(btn){
                var newOrder = $(btn).attr(ORDER_ATTR);
                if(newOrder != undefined){
                    newOrder = (curOrder == 'ASC')? 'DESC':'ASC';
                }else{
                    newOrder = DEF_ORDER;
                }
                $(btn).attr(ORDER_ATTR, newOrder);
                return newOrder;
            }

            function sortClickLocal(){
                curField = $(this).parent().attr(SORT_ATTR);
                curOrder = getNewOrder(this);
                var fieldIndex = $tableElm.find('th').get().indexOf($(this).parent().get()[0]);
                var ascending = (curOrder == 'ASC');
                var findValue = function(row){
                    return $(row).children('td:eq('+fieldIndex+')').text().toLowerCase();
                };
                var numeric = true;
                $tBody.children('tr').each(function(){
                    var value = findValue(this);
                    if(value != '' && !isNumber(value)){
                        numeric = false;
                        return false;
                    }
                });
                var compare = (ascending)?function(a,b){return a<b}:function(a,b){return a>b};
                var sorted;
                if(numeric){
                    sorted = $tBody.find('tr').sort(function(a,b){
                        var aValue = parseFloat(findValue(a));
                        aValue = aValue || 0; // count NaN as zero
                        return compare(aValue,parseFloat(findValue(b)));
                    });
                }else{
                    sorted = $tBody.find('tr').sort(function(a,b){
                        return compare(findValue(a),findValue(b));
                    });
                }
                $tBody.html(sorted);
                updateArrowDisplay();
            }

            function onSortClickRemote(){
                var newField = $(this).parent().attr(SORT_ATTR);

                var newOrder = getNewOrder(this);

                if(newField != curField){//if new field has changed save it in previous for double sorting
                    prevField = curField;
                    prevOrder = curOrder;
                }
                curOrder = newOrder;
                curField = newField;
                loadFromRemote(curPage );
            }

            function loadFromRemote(pageNum){
                var loadByAjax = $tableElm.attr(LOAD_BY_AJAX_ATTR);
                if(loadByAjax != 'false'){
                    loadAjaxContent(pageNum);
                }else{
                    navigateToSorted(pageNum);
                }
                updateArrowDisplay();
            }

            function getRemoteURL(itemsOnly,pageNum) {
                var tableToken = $tableElm.attr(TOKEN_ATTR);
                var perPage = $tableElm.attr(PER_PAGE_ATTR);
                var sourceUrl = '/sortable_data';//$tableElm.attr(SOURCE_ATTR) || ''; //document.domain +
                var sortStr = curField + ' ' + curOrder;
                var query = $tableElm.attr(QUERY_ATTR);

                var paramsObj = $.deparam.querystring();
                paramsObj.query = query;

                if(!initialRequest){
                    if (prevField) {//use previous order
                        sortStr += ',' + prevField + ' ' + prevOrder;
                    }
                    paramsObj.order_by = sortStr;

                    var filters = {};
                    $filters.each(function(index,selectEl) {
                        var $this = $(this);
                        //   if($this.attr(FILTER_ACTIVE_ATTR)) {
                        var filterKey = $this.attr(FILTER_KEY_ATTR);
                        var filterVal = $this.val();
                        filters[filterKey] = filterVal;
                        //   }
                    });
                    paramsObj.filters = filters;
                }

                if (pageNum) {
                    paramsObj.page = pageNum;
                }

                if(perPage){
                    paramsObj.per_page = perPage;
                }

                paramsObj.table_token = tableToken;

                initialRequest = false;

                return sourceUrl+'?'+ $.param(paramsObj);
            }

            function navigateToSorted(pageNum){
                window.location.href = getRemoteURL(false,pageNum);
            }
            function loadAjaxContent(pageNum){
                showLoader();
                $.ajax({url:getRemoteURL(true, pageNum), dataType: "json"}).done(onAjaxLoaded)
            }

            function showLoader(){
                if(!loaderDiv){
                    loaderDiv = $(document.createElement('div'));
                    loaderDiv.css('position','absolute');
                    loaderDiv.css('opacity','0.4');
                }

                var offset = $tBody.offset();
                loaderDiv.css(offset);
                loaderDiv.width($tBody.width());
                loaderDiv.height($tBody.height());
                try{//TODO why the fail here??
                    $(loaderDiv).progressbar({value: false});
                }catch(er){}
                $('body').append(loaderDiv);//html(loader+$tBody.html());
            }

            function updateArrowDisplay(){
                sortBtns.forEach(function(btn){
                    var icon = null;
                    if(btn.parents('th['+SORT_ATTR+']').attr(SORT_ATTR) == curField){
                        icon = (curOrder == 'ASC')?UP_ICON:DOWN_ICON;
                        btn.attr(ORDER_ATTR, curOrder);//this is repeated in updateOrder...remove the other maybe
                    }
                    btn.button( "option", "icons", { secondary: icon } );
                })
            }

            function onAjaxLoaded(data){
                $(loaderDiv).remove();
                $tBody.html('');
                $(data.rows_data).each(function(index,row){
                    var $tr = $(document.createElement("tr"));
                    var orderedCells = [];
                    for (var prop in row) {
                        if(fields[prop]){
                            var cell = row[prop].val;
                            if(!row[prop].no_display){
                                var $td = $(document.createElement("td"));
                                if(row[prop].path){
                                    var $cell = $(document.createElement("a"));
                                    $cell.attr('href',row[prop].path);
                                    $cell.addClass('link_item');
                                    $cell.html(cell);
                                    $td.addClass('link');
                                    $td.append($cell);
                                }else{
                                    $td.html(cell);
                                }
                                $td.addClass(fields[prop].class);
                                orderedCells[fields[prop].colIndex] = $td;
                            }
                        }
                        $tr.append(orderedCells)
                    }
                    $tr[0].sortableData = row;
                    $tBody.append($tr);
                });

                if(data.rows_data.length == 0){// 0 results returned
                    var $tr = $(document.createElement("tr"));
                    var $td = $(document.createElement("td"));
                    $td.attr('colspan',$tableElm.find('th').length);
                    $td.css('text-align','center').css('background','#eee');
                    $td.html(SortableLocale.noDataMessage);
                    $tr.append($td);
                    $tBody.append($tr);

                }

                if(data.pagination){
                    $paginateContainer.html(data.pagination);
                    initPagination();
                }else{
                    $paginateContainer.html('');//.html('no paginate');
                }
                if(data.filters){
                    filtersLock = true;
                    for(filter_key in data.filters ){
                        var filter_value = data.filters[filter_key];
                        var $filter = getFilterElement(filter_key);
                        $filter.val(filter_value);
                    }
                    filtersLock = false;
                }

                if(data.cur_order && (typeof data.cur_order == 'string')){
                    var splittedOrder = data.cur_order.split(' ');
                    if(splittedOrder.length > 1){
                        curField = splittedOrder[0];
                        curOrder = splittedOrder[1];
                        updateArrowDisplay();
                    }
                }

                var onLoadedCallBack = $tableElm[0].sortableTableOptions.onLoad;
                $tableElm.trigger(EVT_LOADED, data, $tableElm, $tableElm.attr(QUERY_ATTR));
                if(onLoadedCallBack){
                    onLoadedCallBack(data, $tableElm,$tableElm.attr(QUERY_ATTR));
                }

            }
            function getFilterElement(filterKey){
                var $filter = $('nomatch');
                $filters.each(function(){
                    if($(this).attr(FILTER_KEY_ATTR) == filterKey){
                        $filter = $(this);
                        return false;
                    }
                })
                return $filter;
            }
        })
    };

});
