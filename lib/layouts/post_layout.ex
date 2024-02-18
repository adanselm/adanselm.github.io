defmodule Adanselm.PostLayout do
  use Tableau.Layout, layout: Adanselm.RootLayout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <div class="bg-white px-6 py-32 lg:px-8">
      <div class="mx-auto max-w-4xl text-base leading-7 text-gray-700">
        <p class="text-base font-semibold leading-7 text-indigo-600"><%= @page.categories %></p>
        <h1 class="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl"><%= @page.title %></h1>
        <div class="mt-10 max-w-2xl space-y-4 article">
          <%= render @inner_content %>
        </div>
      </div>
    </div>
    """
  end
end
