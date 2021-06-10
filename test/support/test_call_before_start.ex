defmodule TestCallBeforeStart do
  # test calling MoxEnv config get before Mox.Server started

  @test_key App.test_key()

  def test_key do
    @test_key
  end
end
