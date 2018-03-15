from django.conf.urls import url

from . import views

urlpatterns = [

	url(r'^cRic/$', views.index, name='index'),
	url(r'^cRic/about$', views.about, name='about'),
	url(r'^cRic/download$', views.download, name='download'),
	url(r'^cRic/doc$', views.doc, name='doc'),
	
	# CircRNA expression
    url(r'^cRic/expr/$', view=views.expr, name='expr'),
	url(r'^cRic/api/expr/$', view=views.api_expr, name='api_expr'),
	
	url(r'^cRic/api/expr/png/(?P<png_name>.*)$', view=views.expr_table_png, name='expr_table_png'),
	
	# Correlation
	url(r'^cRic/cor/$', view=views.cor, name='cor'),
	url(r'^cRic/api/cor/$', view=views.api_cor, name='api_cor'),

	url(r'^cRic/api/cor/png/(?P<png_name>.*)$', view=views.cor_table_png, name='cor_table_png'),

	# Drug
	url(r'^cRic/drug/$', view=views.drug, name='drug'),
	url(r'^cRic/api/drug/$', view=views.api_drug, name='api_drug'),
	url(r'^cRic/api/drug/png/(?P<png_name>.*)$', view=views.drug_table_png, name='drug_table_png'),

	# Comprehensive
	url(r'^cRic/bind/$', view=views.bind, name='bind'),
	url(r'^cRic/api/rbp/$', view=views.api_rbp, name='api_rbp'),
	url(r'^cRic/api/mirna/$', view=views.api_mirna, name='api_mirna'),

	url(r'^cRic/api/mrna/$', view=views.api_mrna, name='api_mrna'),
	url(r'^cRic/api/mrna/png/(?P<sid>.*)$', view=views.mrna_table_png, name='mrna_table_png'),

	url(r'^cRic/api/protein/$', view=views.api_protein, name='api_protein'),
	url(r'^cRic/api/protein/png/(?P<sid>.*)$', view=views.protein_table_png, name='protein_table_png'),

	url(r'^cRic/api/mutation/$', view=views.api_mutation, name='api_mutation'),
	url(r'^cRic/api/mutation/png/(?P<sid>.*)$', view=views.mutation_table_png, name='mutation_table_png'),

	# Autocomplete
	url(r'^cRic/api/cclid/$', view= views.api_ccl_identifier, name='api_ccl_identifier'),
	url(r'^cRic/api/autoccl/(?P<search>.*)$', view=views.api_autocomplete_ccl, name='api_autocomplete_ccl'),
	url(r'^cRic/api/autosym/(?P<search>.*)$', view=views.api_autocomplete_symbol, name='api_autocomplete_symbol'),
	url(r'^cRic/api/autogdsc/(?P<search>.*)$', view=views.api_autocomplete_gdsc, name='api_autocomplete_gdsc'),
	url(r'^cRic/api/autoccle/(?P<search>.*)$', view=views.api_autocomplete_ccle, name='api_autocomplete_ccle'),
	
]
