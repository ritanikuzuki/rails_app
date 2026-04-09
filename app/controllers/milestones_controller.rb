class MilestonesController < ApplicationController
  before_action :set_task
  before_action :set_milestone, only: [:update, :destroy, :toggle]

  def create
    @milestone = @task.milestones.new(milestone_params)
    @milestone.position = @task.milestones.count + 1

    if @milestone.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @task, notice: "マイルストーンを追加しました" }
      end
    else
      redirect_to @task, alert: "マイルストーンの追加に失敗しました"
    end
  end

  def update
    if @milestone.update(milestone_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @task, notice: "マイルストーンを更新しました" }
      end
    else
      redirect_to @task, alert: "マイルストーンの更新に失敗しました"
    end
  end

  def destroy
    @milestone.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task, notice: "マイルストーンを削除しました" }
    end
  end

  def toggle
    @milestone.toggle_complete!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task, notice: "マイルストーンの状態を更新しました" }
    end
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  end

  def set_milestone
    @milestone = @task.milestones.find(params[:id])
  end

  def milestone_params
    params.require(:milestone).permit(:title, :due_date)
  end
end
