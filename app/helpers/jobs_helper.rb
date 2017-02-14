module JobsHelper
  def active_vdi_jobs_to_json(job)
    {
      'User'         => job.user.name,
      'InstanceType' => job.instancetype ? job.instancetype.name : "",
      'Usage'        => job.usage,
      'OS'           => job.template ? job.template.platform : "",
      'Cost'         => job.cost,
      'Zone'         => job.region
    }   
  end
end
