class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete]

  def index
    @tasks = current_user.tasks

    case current_mode
    when "amount"
      @tasks = @tasks.by_amount
    when "created"
      @tasks = @tasks.by_created
    when "daily"
      @date = params[:date] ? Date.parse(params[:date]) : Date.current
      @tasks = @tasks.by_date(@date)
    when "monthly"
      @month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.current
      @tasks = @tasks.by_month(@month)
    else
      @tasks = @tasks.by_amount
    end
  end

  def show
    @milestones = @task.milestones
  end

  def new
    @task = current_user.tasks.new
    @task.priority = 3
    @task.due_date = Date.current + 7
  end

  def create
    @task = current_user.tasks.new(task_params)
    @task.status = :pending

    if @task.save
      redirect_to @task, notice: "タスクを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "タスクを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path(mode: current_mode), notice: "タスクを削除しました"
  end

  def complete
    @task.mark_complete!
    redirect_to @task, notice: "タスクを完了しました！🎉"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :penalty_amount, :priority, :start_date, :due_date, :status)
  end
end
