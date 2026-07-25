import sys
import os
import torch
import rasterio
import deepbiosphere.Run as run
import deepbiosphere.NAIP_Utils  as naip

filename  = sys.argv[1]

subdir = filename.split("_")[1][:5]

raster_path = os.path.join("/storage/home/kbl5733/gstorage/data/deepflora/SCRATCH/pa_100cm_2017",subdir,filename)
exp_id = "db_pa_2017"
band = -1
loss = 'SAMPLE_AWARE_BCE'
model = 'DEEPBIOSPHERE'
epoch = 8
save_dir = "/storage/home/kbl5733/gstorage/data/deepflora/maps/tiles/"
save_name = "pa_30m_" + filename

raster = rasterio.open(raster_path)
cfg = run.load_config(exp_id=exp_id, band=band, loss=loss, model=model)
device = torch.device("cuda:0")
deepbio = run.load_model(device, cfg, epoch, eval_=True) 
deepbio = deepbio.to(device)
files = naip.predict_raster(raster,
                save_dir=save_dir,
                save_name=save_name,
                model=deepbio,
                model_config=cfg,
                device=device,
                batch_size=100,
                pred_types = ['RAW'],
                resolution = 30,
                impute_climate=True, 
                clim_rasters=None)
