import torch
import rasterio
import deepbiosphere.Run as run
import deepbiosphere.NAIP_Utils  as naip

raster_path = "~/gstorage/data/deepflora/SCRATCH/pa_100cm_2017/40077/m_4007710_se_18_1_20170509.tif"
exp_id = "initial"
band = -1
loss = 'SAMPLE_AWARE_BCE'
model = 'DEEPBIOSPHERE'
epoch = 12
save_dir = "~/gstorage/data/deepflora/deepflora_predictions/"
save_name = "initial_state_college"

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
                pred_types = ['raw'],
                resolution = 50,
                impute_climate=True, 
                clim_rasters=None)
