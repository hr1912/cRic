from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt


# Load modules
import os
import json
import commands
import subprocess
import pickle
import re

# resources and rscripts

rcommand = commands.getoutput("which Rscript")
root_path = os.path.dirname(os.path.abspath(__file__))
rscript_dir = os.path.join(root_path, 'rscripts')
resource_jsons = os.path.join(root_path, 'resource', 'jsons')
resource_pngs = os.path.join(root_path, 'resource', 'pngs')
resource_data = os.path.join(root_path, 'resource', 'data')

# Create your views here.

def index(request):
	title = "cRic"
	context = {"title": title}
		
	return render(request=request, template_name="cric/home.html", context=context, status=200)

def about(request):
	title = "About"
	context = {"title": title}

	return render(request, "cric/about.html", context, status=200)

def download(request):
	title = "Download"
	context = {"title": title}

	return render(request, "cric/download.html", context, status=200)

def doc(request):
	title = "Document"
	context = {"title": title}

	return render(request, "cric/document.html", context, status=200)

def expr(request):
	title = "Expression"
	context = {"title": title}

	return	render(request, "expr/expr.html", context, status=200)

@csrf_exempt
def api_ccl_identifier(request):
	search = request.POST.get('q')
	pickle_file = os.path.join(resource_data, "ccl_names.pickle")
	list = pickle.load(open(pickle_file, "rb"))
 
	if search in list:
		return JsonResponse({"query": search,"result": "in"}, safe=False)	
	return JsonResponse({"query": search,"result": "out"}, safe=False)
	
### autocomplete
def api_autocomplete_ccl(request, search):
	title = "API | ccl autocomplete"
	context = {"title": title}

	pickle_file = os.path.join(resource_data, "ccl_symbol.pickle")
	list = pickle.load(open(pickle_file,"rb"))
	regex = re.compile(search, re.IGNORECASE)	

	data = filter(regex.search, list)[0:10]
	return JsonResponse(data, safe=False)

def api_autocomplete_symbol(request, search):
	title = "API | symbol autocomplete"
	context = {"title": title}

	pickle_file = os.path.join(resource_data, "symbol_names.pickle")
	list = pickle.load(open(pickle_file, "rb"))
	regex = re.compile(search, re.IGNORECASE)

	data = filter(regex.search, list)[0:10]
	return JsonResponse(data, safe=False)

def api_autocomplete_gdsc(request, search):
	title = "API | gdsc autocomplete"
	context = {"title": title}

	pickle_file = os.path.join(resource_data, "gdsc_symbol.pickle")
	list = pickle.load(open(pickle_file, "rb"))
	regex = re.compile(search, re.IGNORECASE)

	data = filter(regex.search, list)[0:10]
	return JsonResponse(data, safe=False)

def api_autocomplete_ccle(request,search):
	title = "API | ccle autocomplete"
	context = {"title": title}

	pickle_file = os.path.join(resource_data, "ccle_symbol.pickle")
	list = pickle.load(open(pickle_file, "rb"))
	regex = re.compile(search, re.IGNORECASE)

	data = filter(regex.search, list)[0:10]
	return JsonResponse(data, safe=False)

def api_expr(request):
	title = "API | CircRNA expression"
	context = {"title": title}
	
	q = request.GET['q']
	#q = "SORT1" || "COR-L24"

	rscript = os.path.join(rscript_dir, "api_expr.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_expr", q, "json"]))
	
	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def expr_table_png(request, png_name):

	png_file = os.path.join(resource_pngs, png_name)

	if os.path.exists(png_file):
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
	else:
		return HttpResponse(png_file, content_type="text/plain")

def cor(request):
	title = "Correlation"
	context = {"title": title}

	return render(request, "cor/cor.html", context, status=200)

def api_cor(request):
	title = "API | Correlations"
	context = {"title": title}

	q = request.GET['q']

	rscript = os.path.join(rscript_dir, "api_cor.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_cor", q, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def cor_table_png(request, png_name):

	png_file = os.path.join(resource_pngs, png_name)

	if os.path.exists(png_file):
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
	else:
		return HttpResponse(png_file, content_type="text/plain")

def drug(request):
	title = "Drug"
	context = {"title": title}

	return render(request, "drug/drug.html", context, status=200)

def api_drug(request):
	title = "API | Drug"
	context = {"title": title}

	q = request.GET['q']
	db = request.GET['db']

	rscript = os.path.join(rscript_dir, "api_drug.R")
	cmd = [rcommand, rscript, root_path, q, db]
	json_file = os.path.join(resource_jsons, ".".join(["api_drug", q, db, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def drug_table_png(request, png_name):

	png_file = os.path.join(resource_pngs, png_name)

	if os.path.exists(png_file):
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
	else:
		return HttpResponse(png_file, content_type="text/plain")

def bind(request):
	title = "Bind"
	context = {"title": title}

	return render(request, "bind/bind.html", context, status=200)

def api_rbp(request):
	title = "API | rbp"
	context = {"title": title}

	q = request.GET['q']

	rscript = os.path.join(rscript_dir, "api_bind.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_bind", "RBP", q, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def api_mirna(request):
	title = "API | mirna"
	context = {"title": title}

	q = request.GET['q']

	rscript = os.path.join(rscript_dir, "api_bind.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_bind", "miRNA", q, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def api_mrna(request):
	title = "API | mrna"
	context = {"title": title}

	q = request.GET['q']

	rscript = os.path.join(rscript_dir, "api_mrna.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_mrna", q, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def mrna_table_png(request, sid):

	rscript = os.path.join(rscript_dir, "api_mrna_plot.R")

	cmd = [rcommand, rscript, root_path, sid]
	q1,q2 = sid.split("-")

	png_name =".".join(["api_mrna", q1, q2, "png"])
	png_file = os.path.join(resource_pngs, png_name)

	if os.path.exists(png_file):
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
	else:
		subprocess.check_output(cmd, universal_newlines=True)
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")

def api_protein(request):
	title = "API | protein"
	context = {"title": title}

	q = request.GET['q']

	rscript = os.path.join(rscript_dir, "api_protein.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_protein", q, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def protein_table_png(request, sid):

	rscript = os.path.join(rscript_dir, "api_protein_plot.R")

	cmd = [rcommand, rscript, root_path, sid]
	q1,q2 = sid.split("-")

	png_name =".".join(["api_protein", q1, q2, "png"])
	png_file = os.path.join(resource_pngs, png_name)

	if os.path.exists(png_file):
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
	else:
		subprocess.check_output(cmd, universal_newlines=True)
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")

def api_mutation(request):
	title = "API | mutation"
	context = {"title": title}

	q = request.GET['q']

	rscript = os.path.join(rscript_dir, "api_mutation.R")
	cmd = [rcommand, rscript, root_path, q]
	json_file = os.path.join(resource_jsons, ".".join(["api_mutation", q, "json"]))

	if not os.path.exists(json_file):
		subprocess.check_output(cmd, universal_newlines=True)

	data = json.load(open(json_file, 'r'))
	return JsonResponse(data, safe=False)

def mutation_table_png(request, sid):

	rscript = os.path.join(rscript_dir, "api_mutation_plot.R")

	cmd = [rcommand, rscript, root_path, sid]
	q1,q2 = sid.split("-")

	png_name =".".join(["api_mutation", q1, q2, "png"])
	png_file = os.path.join(resource_pngs, png_name)

	if os.path.exists(png_file):
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
	else:
		subprocess.check_output(cmd, universal_newlines=True)
		with open(png_file) as f:
			return HttpResponse(f.read(), content_type="image/png")
			