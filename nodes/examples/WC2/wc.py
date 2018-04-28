#!/usr/bin/python
# -*- coding: utf-8 -*

#Pour travailler sur les sources
import sys
sys.path.insert(0,'../FUTIL')
from FUTIL.my_logging import *

from pymongo import MongoClient
import calendar
from datetime import datetime, timedelta
import matplotlib
import matplotlib.pyplot as plt

class tempe_db(object):
	'''A database Mongodb pour stocker données tempeDB
	'''
	def __init__(self, host = '127.0.0.1', port = 27017, db_name = 'maison', date_debut = None, date_fin = None):
		'''Initialisation
			- host				:	mongodb host (default : localhost)
			- port				:	mongodb port (default : 27017)
			- db_name			;	database name (default : 'tempeDB')
			- date_debut
			- date_fin
		'''
		self.client = MongoClient(host, port)
		self.db = self.client[db_name]
		self.datas = self.db.datas
		self.values = self.db.values
		self.date_debut = date_debut
		self.date_fin = date_fin
	
	def mesures(self, topic):
		'''renvoie un iterable avec les mesures
		'''
		#TODO : ajouter des critères (batch, dates)
		criteres = {}
		if self.date_debut or self.date_fin:
			criteres['date']={}
		if self.date_debut:
			criteres['date']['$gte']=self.date_debut
		if self.date_fin:
			criteres['date']['$lte']=self.date_fin
		criteres['topic'] = topic
		return self.datas.find(criteres).sort('date')
	
	@staticmethod
	def utc_to_local(utc_dt):
		''' Transforme une date UTC en date locale naive
		'''
		timestamp = calendar.timegm(utc_dt.timetuple())
		local_dt = datetime.fromtimestamp(timestamp)
		assert utc_dt.resolution >= timedelta(microseconds=1)
		return local_dt.replace(microsecond=utc_dt.microsecond)
		
class WC_ui(object):
	def __init__(self, bdd):
		'''Initialisation
			- bdd			:	base de données tempe_db
		'''
		self.bdd = bdd
		self.dates = []
		self.MQ2 = []
		self.lecture_donnees()
		self.fig = plt.figure()
		self.fig.canvas.set_window_title('TempeDB - WC')
		self.init_graphes()
		matplotlib.use('GTKAgg') 
		
	def run(self):
		'''Run the ui
		'''
		plt.show()
	
	def lecture_donnees(self):
		'''lecture de la base de données et correction des données
		'''
		logging.info('Lecture des données')
		for data in self.bdd.mesures('T-HOME/WC/MQ-5'):
			try:	
				self.dates.append(tempe_db.utc_to_local(data['date']))
				self.MQ2.append(data['payload'])
			except Exception as e:
				print(e)
		logging.info("%s mesures trouvées."%(len(self.dates)))
		
		#Facteur de moyenne mobile
		k = 50
		s = 0
		self.MQ2_mod = []
		for i in range(len(self.MQ2)):
			s += self.MQ2[i]
			if i < k:
				self.MQ2_mod.append(self.MQ2[i]/(s/(i+1)))
			else:
				s -= self.MQ2[i-k]
				self.MQ2_mod.append(self.MQ2[i]/(s/k))

	def init_graphes(self):
		''' Inititialise les graphiques
		'''
		self.graphe_MQ2=self.fig.add_subplot(121)
		self.graphe_MQ2.plot(self.dates, self.MQ2, label='MQ2')
		self.graphe_MQ2.legend() 

		self.graphe_MQ2_mod=self.fig.add_subplot(122, sharex = self.graphe_MQ2)
		self.graphe_MQ2_mod.plot(self.dates, self.MQ2_mod, label='MQ2_mod')
		self.graphe_MQ2_mod.legend() 

my_logging(console_level = DEBUG, logfile_level = DEBUG, details = True)
mybdd = tempe_db(host = '192.168.10.174', date_debut = datetime(2017,3,27))
my_ui = WC_ui(mybdd)
my_ui.run()