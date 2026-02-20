source("scripts/azure_from_index.R")

naipshp <- azure_from_index("https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_shpfl_2017/index.html")

for(i in seq_along(naipshp)){
  download.file(naipshp[i], file.path("data","naipshp",basename(naipshp[i])))
}



~/gstorage/data/deepflora/SCRATCH/pa_100cm_2017/40077/m_4007710_se_18_1_20170509.tif
