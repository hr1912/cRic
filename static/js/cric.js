/*
cRic main js
Depends on JQuery v1.12.4, jquer-ui v1.12.1, dataTable v.1.10.1

*/

var cric=(function() {
	
	var EXPR_TABLE;
	var COR_TABLE;
	var DRUG_TABLE;
	var RBP_TABLE;
	var MIRNA_TABLE;
	var GENERIC_TABLE;

	var by_ccl;
	var by_drug;

	var global_datatable_settings = {

		dom: 'Bfrtip',
		buttons:[
			'copy', 'csv', 'excel'
		],

		processing: true,
		stateSave: true,
		//bDestroy: true,
		language: {
			decimal: ",",
			emptyTable: "No CircRNA identified for/associates with this gene/cell line/drug!"
		},

		}, 
		expr_datatable_settings = {

			"columns": [
				{data: "circ"},
				{data: "num_ccl"},
				{data: "reads"},
				{data: "num_ct"},
				//{data: "ccl_name"},
				//{data: "circ_gene"},
				{
                	className: 'details-control',
                	orderable:  false,
                	data:       null,
                	defaultContent: ''
            	}

			],

			"order": [[1, 'desc'], [3, 'desc'], [2, 'desc']]

		},
		expr_datatable_ccl_settings = {

			"columns": [
				{data: "circ"},
				{data: "ccl_name"},
				{data: "reads"},
				{data: "type"}
			],

			"order": [[2, 'asc']]

		},
		cor_datatable_settings = {

			"columns": [
				{data: "gene"},
				{data: "estimate"},
				{data: "fdr"},
				{data: "type"},
				{
					className: 'details-control',
					orderable: 	false,
					data: null, 	
					defaultContent: ''
				}
			],

			"order": [[0, 'asc']]

		},
		drug_datatable_settings = {

			"columns": [
				{data: "circ_gene"},
				{data: "drug"},
				{data: "diff"},
				{data: "fdr"}
			/*
				{
					className: 'details-control',
					orderable: false,
					data: null,
					defaultContent: ''
				}
			*/
			],

			"order": [[2, 'asc']]
		},
		mrna_datatable_settings = {

			"columns": [
				{data: "circRNA"},
				{data: "mRNA_gene"},
				{data: "difference"},
				{data: "fdr"},
				{
                	className: 'details-control',
                	orderable:  false,
                	data:       null,
                	defaultContent: ''
            	}
			],

			"order": [[2, 'desc']]

		},
		protein_datatable_settings = {

			"columns": [
				{data: "circRNA"},
				{data: "protein"},
				{data: "protein_gene"},
				{data: "difference"},
				{data: "fdr"},
				{
                	className: 'details-control',
                	orderable:  false,
                	data:       null,
                	defaultContent: ''
            	}
			],

			"order": [[3, 'desc']]

		},
		mutation_datatable_settings = {

			"columns": [
				{data: "circRNA"},
				{data: "mutated_gene"},
				{data: "fdr"},
				{data: "type"},
				{
                	className: 'details-control',
                	orderable:  false,
                	data:       null,
                	defaultContent: ''
            	}
			],

			"order": [[2, 'asc']]

		},
		rbp_datatable_settings = {

			"columns": [
				{data: "circRNA"},
				{data: "RBP"},
				{data: "query_gene"},
			],

			"order": [[0, 'asc']]

		},
		mirna_datatable_settings = {

			"columns": [
				{data: "circ"},
				{data: "miRNA"},
				{data: "query_gene"},
			],

			"order": [[0, 'asc']]

		};

	function format_expr_table(d) {

		var img_path = '/cRic/api/expr/png/api_expr.' + 
			  d.circ + '.png' ;

		//console.log(d.gene);

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		//console.log(img);

		return 	'<table>' +
			'<tr>' +
				'<td>'+ img + '</td>' +
			'</tr>' +
		'</table>';

	}


	function format_cor_table(d) {

		var img_path = '/cRic/api/cor/png/api_cor.' + 
			d.gene + '.png' ;

		//console.log(d.gene);

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		//console.log(img);

		return 	'<table>' +
			'<tr>' +
				'<td>'+ img + '</td>' +
			'</tr>' +
		'</table>';

	}

	function format_drug_table(d, db) {

		var img_path = '/cRic/api/drug/png/api_drug.' + 
			d.circ_gene + '.' + db +'.png' ;

		//console.log(d.gene);

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		//console.log(img);

		return 	'<table>' +
			'<tr>' +
				'<td>'+ img + '</td>' +
			'</tr>' +
		'</table>';

	}

	function format_mrna_table(d) {

		var img_path = '/cRic/api/mrna/png/' +
			d.circRNA + '-' + d.mRNA_gene ;

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		//console.log(img);

		return 	'<table>' +
			'<tr>' +
				'<td>'+ img + '</td>' +
			'</tr>' +
		'</table>';

	}

	function format_mutation_table(d) {

		var img_path = '/cRic/api/mutation/png/' +
			d.circRNA + '-' + d.mutated_gene ;

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		//console.log(img);

		return 	'<table>' +
			'<tr>' +
				'<td>'+ img + '</td>' +
			'</tr>' +
		'</table>';

	}

	function format_protein_table(d) {

		var img_path = '/cRic/api/protein/png/' +
			d.circRNA + '-' + d.protein_gene ;

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		//console.log(img);

		return 	'<table>' +
			'<tr>' +
				'<td>'+ img + '</td>' +
			'</tr>' +
		'</table>';

	}

	function check_input_autocomplete_ccl() {
        var selector = "#circrna";
        	
        $(selector).autocomplete({
            autoFocus: true,
            source: function(request, response){
                var url = '/cRic/api/autoccl' + "/" + request.term.trim();
                $.getJSON(
                   	url,
                    function(data){
                        response(data);
                    }
                );
            },
            //select: function(event, ui){
              //  showSuccess(this);
            //}
        });
    }

    function check_input_autocomplete_sym() {

    	var selector = "#circrna";

    	$(selector).autocomplete({

    		autoFocus: true,
    		source: function(request, response) {
    			var url = '/cRic/api/autosym/' + request.term.trim();
    			$.getJSON(
    				url,
    				function(data) {
    					response(data);
    				}
    			)
    		},

    	});

    }

    function check_input_autocomplete_drug() {

    	var selector = "#circrna";

    	//console.log(db);
    	$(selector).autocomplete({

    		autoFocus: true,
    		source: function(request, response) {

    			var db = $("#select_drug_db").val();
    			if (db == "gdsc") {
    				var url = '/cRic/api/autogdsc/' + request.term.trim();
    				$.getJSON(
    					url,
    					function(data) {
    						response(data);
    					}
    				)
    			} else {
    				var url = '/cRic/api/autoccle/' + request.term.trim();
    				$.getJSON(
    					url,
    					function(data) {
    						response(data);
    					}
    				)
    			}

    			//console.log(url);
    		},

    	});

    }	

	function reset_expr() {

		if ($.fn.dataTable.isDataTable("#circrna_expr_table")) {
			//console.log("clean datatable!");
			$("#circrna_expr_table").DataTable().destroy();
			//$("#circrna_expr_table").DataTable().clear();
		}

		if ($.fn.dataTable.isDataTable("#circrna_expr_table_ccl")) {
			//console.log("clean datatable!");
			$("#circrna_expr_table_ccl").DataTable().destroy();
			//$("#circrna_expr_table_ccl").DataTable().clear();
		}

		$(".analyses").hide();
		//console.log("reset_expr!");

	}

	function reset_expr() {

		$('input[name=optradio]:checked','#select_analysis').prop('checked',false);
	}

	function retrieve_table_json(module) {

		var m = module.m;
		var q = module.q;

		var url;

		switch(m) {

			case "expr":
				url = "/cRic/api/expr";
				break;
			case "cor":
				url = "/cRic/api/cor";
				break;
			case "drug":
				url = "/cRic/api/drug";
				break;
			case "rbp":
				url = "/cRic/api/rbp";
				break;
			case "mirna":
				url = "/cRic/api/mirna";
				break;
			case "mrna":
				url = "/cRic/api/mrna";
				break;
			case "mutation":
				url = "/cRic/api/mutation";
				break;
			case "protein":
				url = "/cRic/api/protein";
				break;

		}

		var datatable_json;

		if (m == "drug") {

		datatable_json = {

			"ajax" :{
				"url": url,
				"data": {"q":q,
						"db":module.db},
				"dataType": "json",
				"dataSrc": ""
			}
		}

		} else {

		datatable_json = {

			"ajax" :{
				"url": url,
				"data": {"q":q},
				"dataType": "json",
				"dataSrc": ""
			}
		}	

		}

		return datatable_json;		
	}

	function handleResponse(data) {
		console.log(data.result);

		//console.log(EXPR_TABLE);
		//console.log(EXPR_TABLE_CCL);
		//console.log(EXPR_TABLE);

		var q = data.query;

		if (data.result == "out") { // query by gene symbol
			
			//console.log(data.result);
			$("#tab1_div").show();

			var expr_datatable = retrieve_table_json({"m":"expr", "q": q});

			//console.log(expr_datatable);

			var dataTableSettings = $.extend(
				expr_datatable,
				expr_datatable_settings,
				global_datatable_settings);


			EXPR_TABLE = $("#circrna_expr_table").DataTable(dataTableSettings);

			$('#circrna_expr_table tbody').on('click', 'td.details-control', function () {
		
        	var tr = $(this).closest('tr');
        	var row = EXPR_TABLE.row( tr );
 
        	if ( row.child.isShown() ) {
            // This row is already open - close it
            	row.child.hide();
            	tr.removeClass('shown');
        	}
        	else {
            	// Open this row
            	row.child( format_expr_table(row.data()) ).show();
            	tr.addClass('shown');
        	}
    		});


		} else {  // query by cancer cell line


			$("#tab2_div").show();
			$('#ccl_img').empty();
				
			var img_path = '/cRic/api/expr/png/api_expr.' + 
			q + '.png' ;

			var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

			$('#ccl_img').prepend(img);

			var expr_datatable = retrieve_table_json({"m":"expr", "q": q});	

			var dataTableSettings = $.extend(
				expr_datatable,
				expr_datatable_ccl_settings,
				global_datatable_settings);

			EXPR_TABLE = $("#circrna_expr_table_ccl").DataTable(dataTableSettings);

		}

	}


	function click_submit_expr() {

		if ($.fn.dataTable.isDataTable("#circrna_expr_table")) {
			
			EXPR_TABLE.destroy();
			EXPR_TABLE.clear();

			//console.log(1);
		}

		if ($.fn.dataTable.isDataTable("#circrna_expr_table_ccl")) {

			EXPR_TABLE.destroy();
			EXPR_TABLE.clear();

			//console.log(2);
		}

		$(".analyses").hide();

		var q = $("#circrna").val();
		console.log(q);

		$.ajax ({
			"type":"POST",
			"dataType": "json",
			"url": "/cRic/api/cclid/",
			"data": {"q":q }

		}).success(function(data) {
			//console.log(data);
			handleResponse(data);
		}).fail(function(){

		});

		
	}
		
	function click_submit_cor() {

		if ($.fn.dataTable.isDataTable("#circrna_cor_table")) {
			COR_TABLE.destroy();
			COR_TABLE.clear();
			$(".analyses").hide();
		}

		var q = $("#circrna").val();

		//location.reload();

		$(".analyses").show();

		var cor_datatable = retrieve_table_json({"m":"cor","q":q});

		var dataTableSettings = $.extend(
			cor_datatable,
			cor_datatable_settings,
			global_datatable_settings
		);


		COR_TABLE = $("#circrna_cor_table").DataTable(dataTableSettings);


		$('#circrna_cor_table tbody').on('click', 'td.details-control', function () {
		
        var tr = $(this).closest('tr');
        var row = COR_TABLE.row( tr );
 
        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
            // Open this row
            row.child( format_cor_table(row.data()) ).show();
            tr.addClass('shown');
        }
    	});
		
	}

	function click_submit_drug() {

		if ($.fn.dataTable.isDataTable("#circrna_drug_table")) {
			DRUG_TABLE.destroy();
			DRUG_TABLE.clear();
			$(".analyses").hide();
		}

		var q = $("#circrna").val();
		var db = $("#select_drug_db").val();
		//DRUG_DB_I = db;

		//location.reload();
		//console.log(db);

		$(".analyses").show();

		$('#plot_img').empty();
				
		var img_path = '/cRic/api/expr/png/api_drug.' + 
			q + '.' + db + '.png' ;

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		$('#plot_img').prepend(img);

		var drug_datatable = retrieve_table_json({"m":"drug", "q":q, "db": db});

		var dataTableSettings = $.extend(
			drug_datatable,
			drug_datatable_settings,
			global_datatable_settings
		);

		DRUG_TABLE = $("#circrna_drug_table").DataTable(dataTableSettings);

	/*
		$('#circrna_drug_table tbody').on('click', 'td.details-control', function () {
		
        var tr = $(this).closest('tr');
        var row = DRUG_TABLE.row( tr );
 
        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
            // Open this row
            row.child( format_drug_table(row.data(), db) ).show();
            tr.addClass('shown');
        }
    	});
    */
    }

    function datatable_destroy() {

    	if ($.fn.dataTable.isDataTable("#circrna_rbp_table")) {
    		//$("#circrna_rbp_table").DataTable().destroy();
    		RBP_TABLE.clear();
    		RBP_TABLE.destroy();
    	}

    	if ($.fn.dataTable.isDataTable("#circrna_mirna_table")) {
    		//$("#circrna_mirna_table").DataTable().destroy();
    		MIRNA_TABLE.clear();
    		MIRNA_TABLE.destroy();
    	}

    	if ($.fn.dataTable.isDataTable("#circrna_generic_table")) {
    		//$("#circrna_generic_table").DataTable().destroy();
    		GENERIC_TABLE.clear();
    		GENERIC_TABLE.destroy();
    	}

    }

    function mrna_process() {

    	var q = $("#circrna").val();

    	$("#generic_div").show();
    /*
    	$('#plot_img').empty();
				
		var img_path = '/cRic/api/expr/png/api_mrna.' + 
			q + '.png' ;

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		$('#plot_img').prepend(img);
	*/

		var table_head = "<tr>" +
						"<th>CircRNA</th>"+
						"<th>mRNA gene</th>"+
						"<th>Difference</th>"+
						"<th>FDR</th>"+
						"<th>Plot</th>"+
						"</tr>" ;

		$('#circrna_generic_table thead').empty();
		$('#circrna_generic_table thead').append(table_head);

		//console.log(GENERIC_TABLE);

    	var mrna_datatable = retrieve_table_json({"m":"mrna", "q":q});

    	//console.log(mrna_datatable);

    	var DataTableSettings = $.extend(
    		mrna_datatable,
    		mrna_datatable_settings,
    		global_datatable_settings);

    	GENERIC_TABLE = $("#circrna_generic_table").DataTable(DataTableSettings);

    	$('#circrna_generic_table tbody').on('click', 'td.details-control', function () {
		
        	var tr = $(this).closest('tr');
        	var row = $('#circrna_generic_table').DataTable().row( tr );
 
        	if ( row.child.isShown() ) {
            // This row is already open - close it
            	row.child.hide();
            	tr.removeClass('shown');
        	}
        	else {
            	// Open this row
            	row.child( format_mrna_table(row.data()) ).show();
            	tr.addClass('shown');
        	}
    	});

    }

    function mutation_process() {

    	var q = $('#circrna').val();

    	$('#generic_div').show();

    /*	
    	$('#plot_img').empty();
				
		var img_path = '/cRic/api/expr/png/api_mutation.' + 
			q + '.png' ;

		var img = '<img src= "' + img_path + '" style="width:100%;height:100%" align="middle">';

		$('#plot_img').prepend(img);
	*/
		var table_head = "<tr>" +
						"<th>CircRNA</th>"+
						"<th>Mutated gene</th>"+
						"<th>FDR</th>"+
						"<th>Type</th>"+
						"<th>Plot</th>"+
						"</tr>" ;

		$('#circrna_generic_table thead').empty();
		$('#circrna_generic_table thead').append(table_head);

		console.log(GENERIC_TABLE);

    	var mutation_datatable = retrieve_table_json({"m":"mutation", "q":q});

    	//console.log(mrna_datatable);

    	var DataTableSettings = $.extend(
    		mutation_datatable,
    		mutation_datatable_settings,
    		global_datatable_settings);

    	GENERIC_TABLE = $("#circrna_generic_table").DataTable(DataTableSettings);

    	$('#circrna_generic_table tbody').on('click', 'td.details-control', function () {
		
        	var tr = $(this).closest('tr');
        	var row = $('#circrna_generic_table').DataTable().row( tr );
 
        	if ( row.child.isShown() ) {
            // This row is already open - close it
            	row.child.hide();
            	tr.removeClass('shown');
        	}
        	else {
            	// Open this row
            	row.child( format_mutation_table(row.data()) ).show();
            	tr.addClass('shown');
        	}
    	});

    }

    function protein_process() {

    	var q = $("#circrna").val();

    	$("#generic_div").show();

		var table_head = "<tr>" +
						"<th>CircRNA</th>"+
						"<th>Protein</th>"+
						"<th>Protein Gene</th>"+
						"<th>Difference</th>"+
						"<th>FDR</th>"+
						"<th>Plot</th>"+
						"</tr>" ;

		$('#circrna_generic_table thead').empty();
		$('#circrna_generic_table thead').append(table_head);

		console.log(GENERIC_TABLE);

    	var protein_datatable = retrieve_table_json({"m":"protein", "q":q});

    	//console.log(mrna_datatable);

    	var DataTableSettings = $.extend(
    		protein_datatable,
    		protein_datatable_settings,
    		global_datatable_settings);

    	GENERIC_TABLE = $('#circrna_generic_table').DataTable(DataTableSettings);

    	$('#circrna_generic_table tbody').on('click', 'td.details-control', function () {
		
        	var tr = $(this).closest('tr');
        	var row = $('#circrna_generic_table').DataTable().row( tr );
 
        	if ( row.child.isShown() ) {
            // This row is already open - close it
            	row.child.hide();
            	tr.removeClass('shown');
        	}
        	else {
            	// Open this row
            	row.child( format_protein_table(row.data()) ).show();
            	tr.addClass('shown');
        	}
    	});
    }

    function bind_process() {

    	//$(".analyses").hide();
    	var q = $("#circrna").val();

		$("#bind_div").show();

		var rbp_datatable = retrieve_table_json({"m":"rbp","q":q});

		var rbpDataTableSettings = $.extend(
			rbp_datatable,
			rbp_datatable_settings,
			global_datatable_settings
		);


		RBP_TABLE = $("#circrna_rbp_table").DataTable(rbpDataTableSettings);

		var mirna_datatable = retrieve_table_json({"m":"mirna","q":q});

		var mirnaDataTableSettings = $.extend(
			mirna_datatable,
			mirna_datatable_settings,
			global_datatable_settings
		);

		MIRNA_TABLE = $("#circrna_mirna_table").DataTable(mirnaDataTableSettings);

		$(".nav-tabs a").click(function(){
			$(this).tab('show');
		});

    }

    function click_submit_bind() {

    	var analysis_id = $('input[name=optradio]:checked','#select_analysis').val();

    	if (typeof analysis_id === 'undefined') {

    		console.log(analysis_id)
    		analysis_id = "mrna"; // using mRNA as default analysis
    		$('#radio_mrna').prop("checked",true);
    	}

   		datatable_destroy();
   		$(".analyses").hide();

    	switch(analysis_id) {
    		case "mrna":
    		mrna_process();
    		break;
    		case "mutation":
    		mutation_process();
    		break;
    		case "protein":
    		protein_process();
    		break;
    		case "bind":
    		bind_process();
    		break;
    	}

	}
		

	return {

		init: function(){

		},

		exprMain: function(){

			$(".analyses").hide();

			check_input_autocomplete_ccl();

			$("#reset").click(function (){
				location.reload();
			});	

			$("#submit").click(function () {
				click_submit_expr();
			});	
		},

		corMain: function(){

			$(".analyses").hide();

			check_input_autocomplete_sym();

			$("#reset").click(function (){
				location.reload();
			});

			$("#submit").click(function () {
				click_submit_cor();
			});	

		},

		drugMain: function(){

			$(".analyses").hide();

			check_input_autocomplete_drug();

			$("#reset").click(function(){
				location.reload();
			});

			$("#submit").click(function(){
				click_submit_drug();
			});

		},

		bindMain: function(){

			$(".analyses").hide();
		
			check_input_autocomplete_sym();

			$("#reset").click(function(){
				location.reload();
			});

			$("#submit").click(function(){
				click_submit_bind();
			});

		}
	}

})();

$(document).ready(function() {

	console.log("ready!");
	cric.init();

	//cric.exprMain();

	switch (window.location.pathname) {
		case "/cRic/expr/":
			cric.exprMain();
			break;
		case "/cRic/cor/":
			cric.corMain();
			break;
		case "/cRic/drug/":
			cric.drugMain();
			break;
		case "/cRic/bind/":
			cric.bindMain();
			break;
	}

});
