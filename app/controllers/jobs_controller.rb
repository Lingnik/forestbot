# frozen_string_literal: true

class JobsController < ApplicationController
  def create
    @job = Job.new(job_params)
    @job.save
    @job.delay.run
    redirect_to @job
  end

  def show
    @job = Job.find(params[:id])
  end

  private

  def job_params
    params.require(:job).permit(:url, :snippet, :timestamp)
  end
end
